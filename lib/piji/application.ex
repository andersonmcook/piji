defmodule Piji.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: PijiWeb.Router, options: [port: 4000]},
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

    strategy =
      if System.get_env("DOCKER") == "true" do
        Cluster.Strategy.Gossip
      else
        Cluster.Strategy.Epmd
      end

    [
      default: [
        config: [hosts: Enum.map(~w(a b)a, &:"#{&1}@#{hostname}")],
        strategy: strategy
      ]
    ]
  end
end
