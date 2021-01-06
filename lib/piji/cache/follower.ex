defmodule Piji.Cache.Follower do
  @moduledoc false

  use GenServer

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

  @doc """
  Stops follower when cache is no longer needed.
  """
  def stop(pid) do
    GenServer.cast(pid, :stop)
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

  def handle_cast(:stop, state) do
    Logger.info("Stopping follower for #{state.id}")

    {:stop, :normal, state}
  end
end
