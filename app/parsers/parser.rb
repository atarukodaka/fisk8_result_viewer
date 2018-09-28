require 'open-uri'
require 'open_uri_redirections'
require 'timeout'
require 'resolv-replace'

module HttpGet
  TIMEOUT = 5
  def get_url(url, read_option: nil)
    begin
      html = Timeout.timeout(TIMEOUT) do
        (read_option) ? open(url, read_option).read : open(url).read
      end
    rescue OpenURI::HTTPError, Errno::ETIMEDOUT, SocketError, Timeout::Error => e
      ##http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
      Rails.logger.warn(e.message)
      puts e.message
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
