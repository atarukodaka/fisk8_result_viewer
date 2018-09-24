require 'open-uri'
require 'open_uri_redirections'

module HttpGet
  def get_url(url, read_option: nil)
    begin
      html = (read_option) ? open(url, read_option).read : open(url).read
    rescue OpenURI::HTTPError, Errno::ETIMEDOUT, SocketError
      ##http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
      msg = "http error on #{url}"
      Rails.logger.warn(msg)
      puts msg
      return nil
    else
      Nokogiri::HTML(html)
    end
  end
end

class Parser
  include HttpGet

  def initialize(verbose: false)
    @verbose = verbose
  end
end
