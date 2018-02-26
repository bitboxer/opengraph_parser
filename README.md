# OpenGraph

A Elixir wrapper for the [Open Graph protocol](http://ogp.me).

## Installation

The package can be installed as:

1. Add `open_graph_extended` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:open_graph_extended, "~> 0.1.0"}]
end
```

## Usage

```elixir
iex(2)> OpenGraphExtended.parse("<!DOCTYPE html><html><head><meta property=\"og:title\" content=\"Some title\"></head><body><h1>Some title</h1></body></html>")

%OpenGraphExtended{description: nil, image: nil, site_name: nil, title: "Some title",
 type: nil, url: nil}
```

## License

OpenGraphExtended Elixir wrapper source code is licensed under the MIT License.
