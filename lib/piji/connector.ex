defmodule Piji.Connector do
  @moduledoc """
  Nodes don't have to be connected to send messages between them.
  If you know the node and registered name of a process, you can call to it from any unconnected node.

  Start a new node with the same cookie.
  From another node:
  `Process.send({Piji.Connector, :"new@Andersons-MBP"}, self(), [])`
  `flush`
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info(from, state) when is_pid(from) do
    IO.puts("Received message")
    Process.send(from, "Hello from Connector on #{node()}", [])
    {:noreply, state}
  end
end
