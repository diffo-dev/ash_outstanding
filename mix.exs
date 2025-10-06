defmodule AshOutstanding.MixProject do
  use Mix.Project

  @name :ash_outstanding
  @version "0.2.1"
  @description "Ash resource extension for implementing Outstanding protocol"
  @github_url "https://github.com/diffo-dev/ash_outstanding"

  def project() do
    [
      app: @name,
      version: @version,
      name: @name,
      description: @description,
      elixir: "~> 1.18",
      consolidate_protocols: Mix.env() != :test,
      start_permanent: Mix.env() == :prod,
      package: package(),
      # ex_doc
      source_url: @github_url,
      homepage_url: "https://diffo.dev/diffo/outstanding",
      docs: [main: "readme", extras: ["README.md"]],
      elixirc_paths: elixirc_paths(Mix.env()),
      # hex.pm stuff
      deps: deps(),
      docs: &docs/0,
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: @name,
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
      CHANGELOG* documentation),
      links: %{
        "GitHub" => @github_url,
        "Author's home page" => "https://www.diffo.dev"
      }
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp deps() do
    [
      {:outstanding, "~> 0.2.4"},
      {:ash, ash_version("~> 3.5")},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.37", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.12", only: [:dev, :test]},
      {:git_ops, "~> 2.7", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.13", only: [:dev, :test]},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  def docs() do
    [
      homepage_url: @github_url,
      source_url: @github_url,
      source_ref: "v#{@version}",
      main: "readme",
      logo: "logos/diffo.jpg",
      extras: [
        "README.md": [title: "Guide"],
        "LICENSE.md": [title: "License"],
        "documentation/dsls/DSL-AshOutstanding.Resource.md": [
          title: "DSL: AshOutstanding.Resource",
          search_data: Spark.Docs.search_data_for(AshOutstanding.Resource)
        ]
      ]
    ]
  end

  defp ash_version(default_version) do
    case System.get_env("ASH_VERSION") do
      nil -> default_version
      "local" -> [path: "../ash"]
      "main" -> [git: "https://github.com/ash-project/ash.git"]
      version -> "~> #{version}"
    end
  end

  defp aliases() do
    [
      docs: ["spark.cheat_sheets", "docs", "spark.replace_doc_links"],
      "spark.cheat_sheets": "spark.cheat_sheets --extensions AshOutstanding.Resource",
      "spark.formatter": ["spark.formatter --extensions AshOutstanding.Resource", "format .formatter.exs"]
    ]
  end
end
