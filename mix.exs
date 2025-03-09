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
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      package: package(),
      deps: deps(),
      docs: &docs/0,
      aliases: aliases(),
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp package() do
    [
      maintainers: ["Matt Beanland"],
      description: @description,
      licenses: ["MIT"],
      links: %{Github: @github_url},
      files: ~w(mix.exs lib .formatter.exs LICENSE.md  README.md),
    ]
  end

  defp deps() do
    [
      {:outstanding, git: "https://github.com/diffo-dev/outstanding/", branch: "4-structs-shouldnt-implement-outstanding-by-default"},
      {:ash, "~> 3.0"},
      {:spark, ">= 2.1.21 and < 3.0.0"},
      {:igniter, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37", only: :dev, runtime: false},
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
