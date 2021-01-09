defmodule Piji.Cache.Leader do
  @moduledoc false

  use GenServer, restart: :transient

  require Logger

  alias Piji.Cache.{Follower, State}

  @data_store Map.new(1..3, &{&1, :rand.uniform()})

  @doc false
  def start_link(id) do
    GenServer.start_link(__MODULE__, State.new(id))
  end

  @doc """
  Gets data from the leader.
  """
  def get_data(pid) do
    GenServer.call(pid, :get_data)
  end

  def replicate(pid, state) do
    GenServer.cast(pid, {:replicate, state})
  end

  @impl true
  def init(state) do
    case fetch_data(state.id) do
      :no_record ->
        Logger.info("No data for ID: #{state.id}")
        {:stop, :no_data}

      data ->
        Logger.info("Starting leader for #{state.id}")
        state = %{state | data: data, updated_at: DateTime.utc_now()}
        {:ok, state, {:continue, :join}}
    end
  end

  @impl true
  def handle_continue(:join, state) do
    case :pg.get_members(state.id) do
      [] ->
        :rpc.multicall(DynamicSupervisor, :start_child, [
          Piji.DynamicSupervisor,
          {Follower, state}
        ])

      followers ->
        Enum.each(followers, &replicate(&1, state))
    end

    :pg.join(state.id, self())

    {:noreply, state}
  end

  @impl true
  def handle_call(:get_data, _from, state) do
    {:reply, state.data, state}
  end

  @impl true
  def handle_cast({:update, data, updated_at}, state) do
    {:noreply, %{state | data: data, updated_at: updated_at}}
  end

  # Dummy data
  defp fetch_data(id) do
    Map.get(@data_store, id, :no_record)
  end
end
