defmodule OpenGraphTest do
  use ExUnit.Case
  doctest OpenGraph

  setup do
    github = File.read!("#{File.cwd!()}/test/fixtures/github.html")
    youtube = File.read!("#{File.cwd!()}/test/fixtures/youtube.html")
    imgur = File.read!("#{File.cwd!()}/test/fixtures/imgur.html")
    ft = File.read!("#{File.cwd!()}/test/fixtures/ft.com.html")
    book = File.read!("#{File.cwd!()}/test/fixtures/book.html")
    {:ok, github: github, youtube: youtube, imgur: imgur, ft: ft, book: book}
  end

  test "Parses with valid OpenGraph metatags the Imgur HTML", %{imgur: imgur} do
    og = OpenGraph.parse(imgur)

    assert og.description == "Imgur: The magic of the Internet"
    assert og.image == "https://i.imgur.com/L8DIVeu.jpg?fb"
    assert og."image:height" == "315"
    assert og."image:width" == "600"
    assert og.site_name == "Imgur"
    assert og.title == "Das Good Humour Germany"
    assert og.type == "article"
    assert og.url == "https://imgur.com/gallery/MeJNP"
  end

  test "Parses with valid OpenGraph metatags the YouTube HTML", %{youtube: youtube} do
    og = OpenGraph.parse(youtube)

    assert og.description ==
             "EVE Online is the massively multiplayer sci-fi universe that has captivated countless gamers' imaginations for over a decade. \"This is EVE\" takes you into th..."

    assert og.image == "https://i.ytimg.com/vi/AdfFnTt2UT0/maxresdefault.jpg"
    assert og.site_name == "YouTube"
    assert og.title == "“This is EVE” - Uncensored (2014)"
    assert og.type == "video.other"
    assert og.url == "https://www.youtube.com/watch?v=AdfFnTt2UT0"

    assert og."video:height" == "720"
    assert og."video:secure_url" == "https://www.youtube.com/v/AdfFnTt2UT0?version=3&autohide=1"
    assert og."video:type" == "application/x-shockwave-flash"
    assert og."video:width" == "1280"
  end

  test "Parses with valid OpenGraph metatags in the GitHub HTML", %{github: github} do
    og = OpenGraph.parse(github)

    assert og.title == "Build software better, together"
    assert og.url == "https://github.com"
    assert og.site_name == "GitHub"

    assert og.description ==
             "GitHub is where people build software. More than 15 million people use GitHub to discover, fork, and contribute to over 38 million projects."

    assert og.image ==
             "https://assets-cdn.github.com/images/modules/open_graph/github-octocat.png"

    assert og."image:height" == "620"
    assert og."image:width" == "1200"
    assert og.type == "website"
    assert og."image:type" == "image/png"
  end

  test "parses with empty given HTML" do
    og = OpenGraph.parse("")

    assert og == %OpenGraph{}
  end

  test "Parses with wrong opengraph attribute", %{ft: ft} do
    og = OpenGraph.parse(ft)

    assert og.locale == "en_GB"
    assert og.site_name == "Financial Times"
    assert og.type == "website"
    assert og.image == nil
  end

  test "Parses a book", %{book: book} do
    og = OpenGraph.parse(book)

    assert og.locale == "en_US"
    assert og.title == "Steve Jobs"
    assert og.site_name == "Open Graph protocol examples"
    assert og.type == "book"
    assert og.image == "http://examples.opengraphprotocol.us/media/images/50.png"
    assert og."image:height" == "50"
    assert og."image:width" == "50"
    assert og."image:secure_url" == "https://d72cgtgi6hvvl.cloudfront.net/media/images/50.png"
    assert og."image:type" == "image/png"
    assert og.url == "http://examples.opengraphprotocol.us/book-isbn10.html"
    assert og."book:author" == ["http://examples.opengraphprotocol.us/profile.html"]
    assert og."book:isbn" == "1451648537"
    assert og."book:release_date" == "2011-10-24"
    assert og."book:tag" == ["Steve Jobs", "Apple", "Pixar"]
  end

  test "Parses a book entry with a wrong prefix" do
    book = File.read!("#{File.cwd!()}/test/fixtures/book_with_wrong_isbn_tag.html")
    og = OpenGraph.parse(book)

    assert og.locale == "en_US"
    assert og.title == "Steve Jobs"
    assert og.site_name == "Open Graph protocol examples"
    assert og.type == "book"
    assert og.image == "http://examples.opengraphprotocol.us/media/images/50.png"
    assert og."image:height" == "50"
    assert og."image:width" == "50"
    assert og."image:secure_url" == "https://d72cgtgi6hvvl.cloudfront.net/media/images/50.png"
    assert og."image:type" == "image/png"
    assert og.url == "http://examples.opengraphprotocol.us/book-isbn10.html"
    assert og."book:author" == ["http://examples.opengraphprotocol.us/profile.html"]
    assert og."book:isbn" == "1451648537"
    assert og."book:release_date" == "2011-10-24"
    assert og."book:tag" == ["Steve Jobs", "Apple", "Pixar"]
  end
end
