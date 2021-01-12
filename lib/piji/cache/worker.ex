defmodule Piji.Cache.Worker do
  @moduledoc false

  use GenServer, restart: :transient

  require Logger

  @doc false
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @doc false
  def get_data(pid) do
    GenServer.call(pid, :get_data)
  end

  @doc false
  def replicate(pid, state) do
    GenServer.cast(pid, {:replicate, state})
  end

  @impl GenServer
  def init(state) do
    Logger.info("Starting cache for ID: #{state.id} on #{node()}")
    {:ok, state, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    case :pg.get_members(state.id) do
      [] ->
        Node.list()
        |> Enum.reject(&(&1 == node()))
        |> :rpc.multicall(DynamicSupervisor, :start_child, [
          Piji.DynamicSupervisor,
          {__MODULE__, state}
        ])

      workers ->
        Enum.each(workers, &replicate(&1, state))
    end

    :pg.join(state.id, self())

    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get_data, _from, state) do
    {:reply, state.data, state}
  end

  @impl GenServer
  def handle_cast({:replicate, state}, _) do
    {:noreply, state}
  end

  def handle_cast({:update, data}, state) do
    {:noreply, %{state | data: data}}
  end
end
