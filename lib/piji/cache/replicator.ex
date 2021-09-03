defmodule Piji.Cache.Replicator do
  @moduledoc """
  Replicates data to workers in other nodes
  """

  use GenServer

  alias Piji.Cache.Worker

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def start_all(id, data) do
    GenServer.cast(__MODULE__, {:start_all, id, data})
  end

  def start_missing(workers, id, data) do
    GenServer.cast(__MODULE__, {:start_missing, workers, id, data})
  end

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:start_all, id, data}, state) do
    # May not have to be a Task, but the idea is to block as little as possible.
    Task.start(fn ->
      :erpc.multicall([Node.self() | Node.list()], DynamicSupervisor, :start_child, [
        Piji.DynamicSupervisor,
        {Worker, %{data: data, id: id}}
      ])
    end)

    {:noreply, state}
  end

  # Filter out nodes that have workers running on them.
  def handle_cast({:start_missing, workers, id, data}, state) do
    Task.start(fn ->
      workers
      |> Enum.reduce(MapSet.new([Node.self() | Node.list()]), &MapSet.delete(&2, node(&1)))
      |> MapSet.to_list()
      |> :erpc.multicall(DynamicSupervisor, :start_child, [
        Piji.DynamicSupervisor,
        {Worker, %{data: data, id: id}}
      ])
    end)

    {:noreply, state}
  end
end
