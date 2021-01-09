defmodule Piji.Cache.Follower do
  @moduledoc false

  use GenServer, restart: :transient

  require Logger

  alias Piji.Cache.State

  @doc false
  def start_link(%State{} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  @doc """
  Get data from follower.
  """
  def get_data(pid) do
    GenServer.call(pid, :get_data)
  end

  @impl true
  def init(state) do
    Logger.info("Starting follower for #{state.id}")

    :pg.join(state.id, self())
    {:ok, state}
  end

  @impl true
  def handle_call(:get_data, _from, state) do
    {:reply, state.data, state}
  end

  @impl true
  def handle_cast({:replicate, state}, _state) do
    Logger.info("Receiving replica")
    {:noreply, state}
  end

  def handle_cast({:update, data, updated_at}, state) do
    {:noreply, %{state | data: data, updated_at: updated_at}}
  end
end
