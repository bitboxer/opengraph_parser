defmodule OpenGraphExtended.Mixfile do
  use Mix.Project

  def project do
    [
      app: :open_graph_extended,
      version: "0.0.4",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:httpoison, :logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.11"},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description do
    """
    A Elixir wrapper for the Open Graph protocol, which supports all properties from the OpenGraph Protocol
    Originally based on Andriel Nuernberg's version at https://github.com/andrielfn/open_graph
    """
  end

  defp package do
    [
      maintainers: ["Thomas Citharel", "Andriel Nuernberg"],
      licenses: ["MIT"],
      links: %{"Framagit" => "https://framagit.org/tcit/open_graph"},
      files: ~w(lib mix.exs README.md LICENSE)
    ]
    end
end
