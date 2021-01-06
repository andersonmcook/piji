defmodule Piji.Cache.State do
  @moduledoc false

  defstruct [:data, :id, :updated_at]

  def new(id) do
    %__MODULE__{id: id}
  end
end
