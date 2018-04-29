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

  defstruct [:title, :type, :image, :url, # Basic fields
    :description, :audio, :determiner, :locale, :site_name, :video, # Optional fields
    :"image:secure_url", :"image:type", :"image:width", :"image:height", :"image:alt", # Image fields
    :"video:secure_url", :"video:type", :"video:width", :"video:height", :"video:alt", # Video fields
    :"audio:secure_url", :"audio:type", # Audio fields
  ]

  @type t :: %OpenGraphExtended{title: String.t, type: String.t, url: String.t,
                                description: String.t, audio: String.t, determiner: String.t,
                                locale: String.t, site_name: String.t, video: String.t,
                                "image:secure_url": String.t, "image:type": String.t,
                                "image:width": String.t, "image:height": String.t,
                                "image:alt": String.t, "video:secure_url": String.t,
                                "video:type": String.t, "video:width": String.t,
                                "video:height": String.t, "video:alt": String.t,
                                "audio:secure_url": String.t, "audio:type": String.t
                              }

  @type html :: String.t | charlist()

  @doc """
  Parses the given HTML to extract the Open Graph objects.

  Args:
    * `html` - raw HTML as a binary string or char list

  This functions returns an OpenGraph struct.
  """

  @spec parse(String.t) :: t()
  def parse(html) when is_binary(html) or is_list(html) do
    data = html
          |> Floki.parse
          |> Floki.find("meta")
          |> Stream.filter(fn metatag -> match?({_, [{_property, _prop}, {_content, _cont}], _}, metatag) end)
          |> Stream.filter(fn {_meta, [{_property, property}, {_content, _}], _} -> filter_og_metatags(property) end)
          |> Stream.flat_map(fn x -> format(x) end)
          |> Enum.into(%{})

    struct(OpenGraphExtended, data)
  end

  defp format({"meta", [{"property", property}, {"content", content}], []}) do
    new_prop = property |> drop_og_prefix |> String.to_atom
    [{new_prop, content}]
  end

  defp format(_) do
    []
  end

  defp filter_og_metatags("og:" <> _property), do: true
  defp filter_og_metatags(_), do: false

  defp drop_og_prefix("og:" <> property), do: property
end
