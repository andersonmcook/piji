defmodule Piji.Tracer do
  @moduledoc false

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def disable do
    GenServer.cast(__MODULE__, {:toggle, false})
  end

  def enable do
    GenServer.cast(__MODULE__, {:toggle, true})
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast({:toggle, boolean}, state) do
    tracer = if boolean, do: self(), else: false
    :seq_trace.set_system_tracer(tracer)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:seq_trace, _label, seq_trace_info, timestamp}, state) do
    # Naively assuming that no events happen at the same time
    {:noreply, add_entry(state, timestamp, seq_trace_info)}
  end

  # Received message with no timestamp
  def handle_info({:seq_trace, _label, _seq_trace_info}, state) do
    {:noreply, state}
  end

  defp add_entry(state, key, {event, serial, from, to, message}) do
    Map.put(state, key, %{
      event: event,
      from: from,
      message: message,
      serial: serial,
      to: to
    })
  end
end
