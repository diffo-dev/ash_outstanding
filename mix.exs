defmodule AshOutstanding.MixProject do
  use Mix.Project

  @name :ash_outstanding
  @version "0.1.0"
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
      # ex_doc
      source_url: @github_url,
      homepage_url: "https://diffo.dev/diffo/outstanding",
      docs: [main: "readme", extras: ["README.md"]],
      # hex.pm stuff
      deps: deps(),
      docs: &docs/0,
      aliases: aliases(),
      package: [
        name: "ash_outstanding",
        licenses: ["MIT"],
        files: ["lib", "mix.exs", "README*", "VERSION*"],
        maintainers: ["Matt Beanland"],
        links: %{
          "GitHub" => @github_url,
          "Author's home page" => "https://www.diffo.dev"
        }
      ]
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp deps() do
    [
      {:outstanding, "~> 0.2.0"},
      {:ash, "~> 3.5"},
      {:spark, ">= 2.1.21 and < 3.0.0"},
      {:igniter, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sourceror, "~> 1.7", only: [:dev, :test], runtime: false},
      {:freedom_formatter, "~> 2.1", only: [:dev, :test], runtime: false},
    ]
  end

  def docs() do
    [
      homepage_url: @github_url,
      source_url: @github_url,
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "Guide"],
        "LICENSE.md": [title: "License"],
        "documentation/dsls/DSL-AshOutstanding.Resource.md": [
          title: "DSL: AshOutstanding.Resource",
          search_data: Spark.Docs.search_data_for(AshOutstanding.Resource),
        ],
      ],
    ]
  end

  defp aliases() do
    [
      docs: ["spark.cheat_sheets", "docs", "spark.replace_doc_links"],
      "spark.cheat_sheets": "spark.cheat_sheets --extensions AshOutstanding.Resource",
      "spark.formatter": ["spark.formatter --extensions AshOutstanding.Resource", "format .formatter.exs"],
    ]
  end
end
