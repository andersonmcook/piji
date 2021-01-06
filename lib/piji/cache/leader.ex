defmodule Piji.Cache.Leader do
  @moduledoc false

  use GenServer

  require Logger

  alias Piji.Cache.{Follower, State}

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
    Logger.info("Starting leader for #{state.id}")

    {:ok, state, {:continue, :join}}
  end

  @impl true
  def handle_continue(:join, state) do
    state = %{state | data: fetch_data(state.id), updated_at: DateTime.utc_now()}

    # maybe we have a configured min/max replicas
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

  # Get most recent copy
  defp fetch_data(_id) do
    %{make_ref() => make_ref()}
  end
end
