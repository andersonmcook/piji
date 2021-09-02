defmodule Piji.Cache do
  @moduledoc """
  Contains functionality for reading, updating, and deleting values from the cache.
  """

  alias __MODULE__.Worker

  @fake_data_store Map.new(1..3, &{&1, :rand.uniform()})

  @doc """
  Deletes data from the cache if the cache exists.
  """
  @spec delete(any) :: :ok
  def delete(id) do
    id
    |> :pg.get_members()
    |> Enum.each(&GenServer.stop/1)
  end

  @doc """
  Gets an item from the cache.
  If no cache is present, it is created.
  """
  @spec get(any) :: any
  def get(id) do
    case :pg.get_members(id) do
      # First request on the cluster
      [] ->
        case Map.get(@fake_data_store, id) do
          nil ->
            nil

          data ->
            Task.start(fn ->
              :erpc.multicall([Node.self() | Node.list()], DynamicSupervisor, :start_child, [
                Piji.DynamicSupervisor,
                {Worker, %{data: data, id: id}}
              ])
            end)

            data
        end

      # Subsequent requests
      # TODO: get data from the worker on this node
      [worker | _] = workers ->
        data = Worker.get_data(worker)

        Task.start(fn ->
          # TODO: over-optimization?
          # Ensure all workers have the same data
          # Enum.each(workers, &Worker.update(&1, data))

          # Start missing workers
          start_missing_workers(workers, %{data: data, id: id})
        end)

        data
    end
  end

  @doc """
  Updates data in the cache if the cache exists.
  """
  @spec update(any, any) :: :not_cached | :ok
  def update(id, data) do
    case :pg.get_members(id) do
      [] ->
        :not_cached

      workers ->
        start_missing_workers(workers, %{data: data, id: id})
        Enum.each(workers, &Worker.update(&1, data))
    end
  end

  defp start_missing_workers(workers, args) do
    workers
    |> Enum.reduce(MapSet.new([Node.self() | Node.list()]), &MapSet.delete(&2, node(&1)))
    |> MapSet.to_list()
    |> :erpc.multicall(DynamicSupervisor, :start_child, [
      Piji.DynamicSupervisor,
      {Worker, args}
    ])
  end
end
