defmodule EctoInterface.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_interface,
      description: "A set of common Ecto interfaces generated on the fly with macros",
      package: %{
        links: %{"GitHub" => "https://github.com/krainboltgreene/ecto_interface.ex"},
        licenses: ["Hippocratic-3.0"]
      },
      version: "1.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.11"},
      {:slugy, "~> 4.1", optional: true},
      {:ecto_sql, "~> 3.0", only: [:docs, :dev, :test]},
      {:ecto_sqlite3, "~> 0.12.0", only: [:docs, :dev, :test]},
      {:postgrex, "~> 0.17.3", only: [:docs, :dev, :test]},
      {:credo, "~> 1.7", only: [:docs, :dev, :test]},
      {:ex_doc, "~> 0.30.9", only: [:docs, :dev]},
      {:earmark, "~> 1.2", only: [:docs, :dev]},
      {:inch_ex, "~> 2.0", only: [:dev, :test]}
    ]
  end
end
