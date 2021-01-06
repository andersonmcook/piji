defmodule Piji.Cache.Leader do
  @moduledoc false

  use GenServer

  alias Piji.Cache.{Follower, State}

  @doc false
  def start_link(id) do
    GenServer.start_link(__MODULE__, State.new(id))
  end

  @impl true
  def init(state) do
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

      list ->
        nil
    end

    :pg.join(state.id, self())

    {:noreply, state}
  end

  @impl true
  def handle_cast(:hey, state) do
    IO.inspect(self(), label: "Hi from Leader: ")
    {:noreply, state}
  end

  # Get most recent copy
  defp fetch_data(_id) do
    %{make_ref() => make_ref()}
  end
end
