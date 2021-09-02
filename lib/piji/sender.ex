defmodule Piji.Sender do
  @moduledoc """
  Sends messages that we can trace.
  """

  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def ping(pid, pid_to_ping) do
    GenServer.cast(pid, {:ping, pid_to_ping})
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:ping, pid_to_ping}, state) do
    :seq_trace.set_token(:send, true)
    :seq_trace.set_token(:receive, true)
    :seq_trace.set_token(:timestamp, true)
    GenServer.cast(pid_to_ping, :pong)
    {:noreply, state}
  end

  def handle_cast(:pong, state) do
    # Disable tracing or IEx and IO will also have traces
    # Could reenable after with :seq_trace.set_token(token)
    _token = :seq_trace.set_token([])
    {:noreply, state}
  end
end
