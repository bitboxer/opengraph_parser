defmodule OpenGraph.Mixfile do
  use Mix.Project

  def project do
    [
      app: :opengraph_parser,
      version: "0.7.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger]
    ]
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
      {:floki, "~> 0.38.0"},
      {:ex_doc, "~> 0.38.0", only: :dev},
      {:credo, "~> 1.7.5", only: :dev},
      {:ex_check, "~> 0.16.0", only: :dev},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    A Elixir wrapper for the Open Graph protocol, which supports all properties from the OpenGraph Protocol
    Originally based on Andriel Nuernberg's version at https://github.com/andrielfn/open_graph and it's fork
    by Thomas Citharel at https://framagit.org/tcit/open_graph
    """
  end

  defp package do
    [
      maintainers: ["Bodo Tasche", "Thomas Citharel", "Andriel Nuernberg"],
      licenses: ["MIT"],
      links: %{"github" => "https://github.com/bitboxer/opengraph_parser"},
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end
end
