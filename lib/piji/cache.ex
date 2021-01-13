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
    # TODO: Maybe get the global members if we're pretending that it's better to hit the cache first?
    case :pg.get_local_members(id) do
      [] ->
        id
        |> fetch_data()
        |> maybe_start_cache()

      [pid | _] ->
        Worker.get_data(pid)
    end
  end

  @doc """
  Updates data in the cache if the cache exists.
  """
  @spec update(any, any) :: :not_cached | :ok
  def update(id, data) do
    case :pg.get_members(id) do
      [] -> :not_cached
      members -> Enum.each(members, &Worker.update(&1, data))
    end
  end

  defp fetch_data(id) do
    {id, Map.get(@fake_data_store, id)}
  end

  defp maybe_start_cache({_, nil}) do
    nil
  end

  defp maybe_start_cache({id, data}) do
    Task.start(fn ->
      case :pg.get_members(id) do
        [] ->
          :rpc.multicall(DynamicSupervisor, :start_child, [
            Piji.DynamicSupervisor,
            {Worker, %{data: data, id: id}}
          ])

        workers ->
          # Update existing workers
          Enum.each(workers, &Worker.update(&1, data))

          # Start missing workers
          workers
          |> Enum.reduce(MapSet.new([Node.self() | Node.list()]), &MapSet.delete(&2, node(&1)))
          |> MapSet.to_list()
          |> :rpc.multicall(DynamicSupervisor, :start_child, [
            Piji.DynamicSupervisor,
            {Worker, %{data: data, id: id}}
          ])
      end
    end)

    data
  end
end
