defmodule Piji.Cache.Follower do
  @moduledoc false

  use GenServer

  alias Piji.Cache.State

  @doc false
  def start_link(%State{} = state) do
    IO.puts("starting follower")
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    :pg.join(state.id, self())
    {:ok, state}
  end

  @impl true
  def handle_cast(:hey, state) do
    IO.inspect(self(), label: "Hi from Follower: ")
    {:noreply, state}
  end
end
