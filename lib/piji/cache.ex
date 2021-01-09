defmodule Piji.Cache do
  @moduledoc """
  Contains functionality for reading, updating, and deleting values from the cache.
  """

  alias __MODULE__.{Follower, Leader}

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
    case :pg.get_local_members(id) do
      [] ->
        case DynamicSupervisor.start_child(Piji.DynamicSupervisor, {Leader, id}) do
          {:error, :no_data} -> :no_data
          {:ok, pid} -> Leader.get_data(pid)
        end

      [pid | _] ->
        Follower.get_data(pid)
    end
  end

  @doc """
  Updates data in the cache if the cache exists.
  """
  @spec update(any, any) :: :not_cached | :ok
  def update(id, data) do
    case :pg.get_members(id) do
      [] -> :not_cached
      members -> Enum.each(members, &GenServer.cast(&1, {:update, data, DateTime.utc_now()}))
    end
  end
end
