defmodule Piji.MixProject do
  use Mix.Project

  def project do
    [
      app: :piji,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Piji.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:libcluster, "~> 3.2"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
