defmodule Piji.Cache do
  @moduledoc false

  def hey(pid) do
    GenServer.cast(pid, :hey)
  end
end
