defmodule Piji.Cache.Worker do
  @moduledoc false

  use GenServer, restart: :transient

  require Logger

  @timeout :timer.minutes(1)

  @doc false
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  @doc false
  def get_data(pid) do
    GenServer.call(pid, :get_data)
  end

  @doc false
  def update(pid, data) do
    GenServer.cast(pid, {:update, data})
  end

  @impl GenServer
  def init(state) do
    Logger.info("Starting cache for ID: #{state.id} on #{node()}")
    {:ok, state, {:continue, :join}}
  end

  @impl GenServer
  def handle_continue(:join, state) do
    :pg.join(state.id, self())
    {:noreply, state, @timeout}
  end

  @impl GenServer
  def handle_call(:get_data, _, state) do
    {:reply, state.data, state, @timeout}
  end

  @impl GenServer
  def handle_cast({:update, data}, state) do
    {:noreply, %{state | data: data}, @timeout}
  end
end
