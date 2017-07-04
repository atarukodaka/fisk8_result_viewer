require 'open-uri'
require 'open_uri_redirections'

module Utils
  def get_url(url, read_option: nil)
    html = (read_option) ? open(url, read_option).read : open(url).read
    Nokogiri::HTML(html)
  end
end  ## module


