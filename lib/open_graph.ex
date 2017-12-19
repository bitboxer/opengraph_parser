defmodule OpenGraphExtended do
  @moduledoc """
  Fetch and parse websites to extract Open Graph meta tags.

  The example above shows how to fetch the GitHub Open Graph rich objects.

  ```
  OpenGraphExtended.fetch("https://github.com")
  %OpenGraphExtended{description: "GitHub is where people build software. More than 15 million...",
  image: "https://assets-cdn.github.com/images/modules/open_graph/github-octocat.png",
  site_name: "GitHub", title: "Build software better, together", type: nil,
  url: "https://github.com"}
  ```
  """

  @metatag_regex ~r/<\s*meta\s(?=[^>]*?\bproperty\s*=\s*(?|"\s*([^"]*?)\s*"|'\s*([^']*?)\s*'|([^"'>]*?)(?=\s*\/?\s*>|\s\w+\s*=)))[^>]*?\bcontent\s*=\s*(?|"\s*([^"]*?)\s*"|'\s*([^']*?)\s*'|([^"'>]*?)(?=\s*\/?\s*>|\s\w+\s*=))[^>]*>/

  defstruct [:title, :type, :image, :url, # Basic fields
    :description, :audio, :determiner, :locale, :site_name, :video, # Optional fields
    String.to_atom("image:secure_url"), String.to_atom("image:type"), String.to_atom("image:width"), String.to_atom("image:height"), String.to_atom("image:alt"), # Image fields
    String.to_atom("video:secure_url"), String.to_atom("video:type"), String.to_atom("video:width"), String.to_atom("video:height"), String.to_atom("video:alt"), # Video fields
    String.to_atom("audio:secure_url"), String.to_atom("audio:type"), # Audio fields
  ]

  @doc """
  Fetches the raw HTML for the given website URL.

  Args:
    * `url` - target URL as a binary string or char list

  This functions returns `{:ok, %OpenGraph{...}}` if the request is successful,
  `{:error, reason}` otherwise.
  """
  def fetch(url) do
    case HTTPoison.get(url, [], [follow_redirect: true]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, OpenGraphExtended.parse(body)}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found :("}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Parses the given HTML to extract the Open Graph objects.

  Args:
    * `html` - raw HTML as a binary string or char list

  This functions returns an OpenGraph struct.
  """
  def parse(html) do
    map = Regex.scan(@metatag_regex, html, capture: :all_but_first)
    |> Enum.filter(&filter_og_metatags(&1))
    |> Enum.map(&drop_og_prefix(&1))
    |> Enum.into(%{}, fn [k, v] -> {k, v} end)
    |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)

    struct(OpenGraphExtended, map)
  end

  defp filter_og_metatags(["og:" <> _property, _content]), do: true
  defp filter_og_metatags(_), do: false

  defp drop_og_prefix(["og:" <> property, content]) do
    [property, content]
  end
end
