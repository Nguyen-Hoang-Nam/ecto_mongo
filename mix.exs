defmodule EctoMongo.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_mongo,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mongodb_driver, "~> 1.0"},
      {:ecto, "~> 3.9"},
      {:make_enumerable, "~> 0.0.1"}
    ]
  end
end
