defmodule OpenGraph do
  @moduledoc """
  Parse websites to extract Open Graph meta tags.

  The example above shows how to fetch the GitHub Open Graph rich objects.

  ```
  Mix.install([
    {:opengraph_parser, "~> 0.4.4"},
    {:req, "~> 0.4.14"}
  ])

  Req.get!("https://github.com").body
  |> OpenGraph.parse(html)

  %OpenGraph{description: "GitHub is where people build software. More than 15 million...",
  image: "https://assets-cdn.github.com/images/modules/open_graph/github-octocat.png",
  site_name: "GitHub", title: "Build software better, together", type: nil,
  url: "https://github.com"}
  ```
  """

  # Basic fields
  defstruct [
    :title,
    :type,
    :image,
    :url,
    # Optional fields
    :description,
    :audio,
    :determiner,
    :locale,
    :site_name,
    :video,
    # Image fields
    :"image:secure_url",
    :"image:type",
    :"image:width",
    :"image:height",
    :"image:alt",
    # Video fields
    :"video:secure_url",
    :"video:type",
    :"video:width",
    :"video:height",
    :"video:alt",
    # Audio fields
    :"audio:secure_url",
    :"audio:type",
    # Book fields
    :"book:author",
    :"book:isbn",
    :"book:release_date",
    :"book:tag",
    :"price:amount",
    :"price:currency",
    :"product:price:amount",
    :"product:price:currency",
    :"fediverse:creator"
  ]

  @type t :: %OpenGraph{
          title: String.t() | nil,
          type: String.t() | nil,
          url: String.t() | nil,
          description: String.t() | nil,
          audio: String.t() | nil,
          determiner: String.t() | nil,
          locale: String.t() | nil,
          site_name: String.t() | nil,
          video: String.t() | nil,
          "image:secure_url": String.t() | nil,
          "image:type": String.t() | nil,
          "image:width": String.t() | nil,
          "image:height": String.t() | nil,
          "image:alt": String.t() | nil,
          "video:secure_url": String.t() | nil,
          "video:type": String.t() | nil,
          "video:width": String.t() | nil,
          "video:height": String.t() | nil,
          "video:alt": String.t() | nil,
          "audio:secure_url": String.t() | nil,
          "audio:type": String.t() | nil,
          "book:author": list(String.t()) | nil,
          "book:isbn": String.t() | nil,
          "book:release_date": String.t() | nil,
          "book:tag": list(String.t()) | nil,
          "price:amount": String.t() | nil,
          "price:currency": String.t() | nil,
          "product:price:amount": String.t() | nil,
          "product:price:currency": String.t() | nil,
          "fediverse:creator": String.t() | nil
        }

  @type html :: String.t() | charlist()

  @doc """
  Parses the given HTML to extract the Open Graph objects.

  Args:
    * `html` - raw HTML as a binary string or char list

  This functions returns an OpenGraph struct.
  """

  @spec parse(String.t()) :: t()
  def parse(html) when is_binary(html) or is_list(html) do
    {:ok, document} = Floki.parse_document(html)

    opengraph_tags = find_opengraph_tags(document)
    other_meta_tags = find_other_tags(document)

    struct(OpenGraph, opengraph_tags ++ other_meta_tags)
  end

  defp find_opengraph_tags(document) do
    allowed_keys = get_allowed_keys()

    document
    |> Floki.find("meta")
    |> Enum.filter(fn metatag ->
      if Floki.attribute(metatag, "property") != nil do
        property = Floki.attribute(metatag, "property") |> List.first()
        filter_og_metatags(property)
      else
        false
      end
    end)
    |> Enum.flat_map(fn x -> format(x, "property") end)
    |> Enum.flat_map(fn x -> replace_books_with_book(x) end)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      if Enum.member?(["book:tag", "book:author"], key) do
        array = Map.get(acc, key, [])
        Map.merge(acc, %{key => Enum.concat(array, [value])})
      else
        Map.merge(acc, %{key => value})
      end
    end)
    |> Enum.filter(fn {key, value} ->
      value != nil && Enum.member?(allowed_keys, key)
    end)
    |> Enum.map(fn {key, value} ->
      {String.to_atom(key), value}
    end)
  end

  def find_other_tags(document) do
    allowed_keys = get_allowed_keys()

    document
    |> Floki.find("meta")
    |> Enum.filter(fn metatag ->
      if Floki.attribute(metatag, "name") != nil do
        name = Floki.attribute(metatag, "name") |> List.first()
        filter_name_metatags(name)
      else
        false
      end
    end)
    |> Enum.flat_map(fn x -> format(x, "name") end)
    |> Enum.filter(fn {key, value} ->
      value != nil && Enum.member?(allowed_keys, key)
    end)
    |> Enum.map(fn {key, value} ->
      {String.to_atom(key), value}
    end)
  end

  defp format(metatag, key) do
    property = Floki.attribute(metatag, key) |> List.first() |> drop_og_prefix()

    content = Floki.attribute(metatag, "content") |> List.first()
    [{property, content}]
  end

  defp replace_books_with_book({key_string, value}) do
    if String.starts_with?(key_string, "books:") do
      new_key = key_string |> String.replace(~r/^books:/, "book:")
      [{new_key, value}]
    else
      [{key_string, value}]
    end
  end

  defp filter_og_metatags("og:" <> _property), do: true
  defp filter_og_metatags("book:" <> _property), do: true
  defp filter_og_metatags("books:" <> _property), do: true
  defp filter_og_metatags("product:" <> _property), do: true
  defp filter_og_metatags(_), do: false

  defp filter_name_metatags("fediverse:creator"), do: true
  defp filter_name_metatags(_), do: false

  defp drop_og_prefix("og:" <> property), do: property
  defp drop_og_prefix(property), do: property

  defp get_allowed_keys do
    Map.keys(OpenGraph.__struct__())
    |> Enum.map(&Atom.to_string(&1))
    |> Enum.filter(fn x -> x !== "__struct__" end)
  end
end
