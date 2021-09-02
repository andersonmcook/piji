defmodule Piji.Tracer do
  @moduledoc false

  use GenServer

  defmodule Entry do
    defstruct [:event, :from, :message, :serial, :to]

    def new({event, serial, from, to, message}) do
      %__MODULE__{
        event: event,
        from: from,
        message: message,
        serial: serial,
        to: to
      }
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  @impl GenServer
  def init(_) do
    :seq_trace.set_system_tracer(self())
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_info({:seq_trace, _label, seq_trace_info, timestamp}, state) do
    # Naively assuming that no events happen at the same time
    {:noreply, Map.put(state, timestamp, Entry.new(seq_trace_info))}
  end

  def handle_info({:seq_trace, _label, _seq_trace_info}, state) do
    IO.puts("received message with no timestamp")
    {:noreply, state}
  end
end
