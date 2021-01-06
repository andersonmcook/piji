defmodule Piji.Cache do
  @moduledoc false

  alias __MODULE__.{Follower, Leader}

  def hey(pid) do
    GenServer.cast(pid, :hey)
  end

  def get(id) do
    case :pg.get_local_members(id) do
      [] ->
        {:ok, pid} = DynamicSupervisor.start_child(Piji.DynamicSupervisor, {Leader, id})
        Leader.get_data(pid)

      [pid | _] ->
        Follower.get_data(pid)
    end
  end
end
