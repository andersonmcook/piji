defmodule Piji.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: Piji.ClusterSupervisor]]},
      %{id: Piji.ProcessGroup, start: {:pg, :start_link, []}},
      {DynamicSupervisor, strategy: :one_for_one, name: Piji.DynamicSupervisor},
      Piji.Connector
    ]

    opts = [strategy: :one_for_one, name: Piji.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    {:ok, hostname} = :inet.gethostname()

    [
      default: [
        config: [hosts: Enum.map(~w(a b)a, &:"#{&1}@#{hostname}")],
        strategy: Cluster.Strategy.Epmd
      ]
    ]
  end
end
