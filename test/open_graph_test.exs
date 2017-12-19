defmodule OpenGraphExtendedTest do
  use ExUnit.Case
  doctest OpenGraphExtended

  setup do
    html = File.read!("#{File.cwd!}/test/fixtures/github.html")
    {:ok, html: html}
  end

  test "parses with valid OpenGraph metatags in the given HTML", %{html: html} do
    og = OpenGraphExtended.parse(html)

    assert og.title == "Build software better, together"
    assert og.url == "https://github.com"
    assert og.site_name == "GitHub"
    assert og.description == "GitHub is where people build software. More than 15 million people use GitHub to discover, fork, and contribute to over 38 million projects."
    assert og.image == "https://assets-cdn.github.com/images/modules/open_graph/github-octocat.png"
    assert og."image:height" == "620"
    assert og."image:width" == "1200"
    assert og.type == "website"
    assert og."image:type" == "image/png"
  end

  test "parses a remote youtube URL " do
    {:ok, og} = OpenGraphExtended.fetch("https://www.youtube.com/watch?v=19wToRIiYWI")

    assert og.title == "«Ouvrez les guillemets», par Usul: la presse et moi"
    assert og.description == "Après avoir humé « L&#39;air de la campagne » lors des élections présidentielle et législatives, Usul rempile avec sa nouvelle chronique politique « Ouvrez les g..."
    assert og.image == "https://i.ytimg.com/vi/19wToRIiYWI/maxresdefault.jpg"
    assert og.site_name == "YouTube"
    assert og.type == "video"
    assert og."video:height" == "720"
    assert og."video:width" == "1280"
    assert og."video:secure_url" == "https://www.youtube.com/v/19wToRIiYWI?version=3&amp;autohide=1"
    assert og."video:type" == "application/x-shockwave-flash"
  end

  test "parses with empty given HTML" do
    og = OpenGraphExtended.parse("")

    assert og.title == nil
    assert og.url == nil
    assert og.site_name == nil
    assert og.description == nil
    assert og.image == nil
  end
end
