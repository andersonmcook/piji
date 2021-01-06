defmodule Piji.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      %{id: Piji.ProcessGroup, start: {:pg, :start_link, []}},
      {DynamicSupervisor, strategy: :one_for_one, name: Piji.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Piji.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
