defmodule Piji.Cache.Leader do
  @moduledoc false

  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  def hey(pid) do
    GenServer.cast(pid, :hey)
  end

  @impl true
  def init(id) do
    :pg.join(id, self())
    {:ok, group, {:continue, :join}}
  end

  @impl true
  def handle_continue(:join, state) do
    # maybe we have a configured min/max replicas
    case :pg.get_members(state) do
      # start followers
      [] -> nil
      # do nothing
      list -> nil
    end

    :pg.join(state, self())
  end

  @impl true
  def handle_cast(:hey, state) do
    IO.inspect(self(), label: "Hi from ")
    {:noreply, state}
  end
end
