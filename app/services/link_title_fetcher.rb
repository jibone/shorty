require 'httparty'

# LinkTitleFetcher fetchers the link title from the header title tag
class LinkTitleFetcher
  def initialize(url)
    @url = url
  end

  def call
    response = HTTParty.get(@url)

    return "" unless response.code == 200

    title = response.body.match(%r{<title>(.*?)</title>}i)[1]

    title || ""
  rescue StandardError
    ""
  end
end
