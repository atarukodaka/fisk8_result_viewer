require 'open-uri'
require 'open_uri_redirections'
require 'timeout'
require 'resolv-replace'

module HttpGet
  include DebugPrint

  TIMEOUT = 10
  def get_url(url, read_option: nil)
    html = Timeout.timeout(TIMEOUT) do
      (read_option) ? open(url, read_option).read : open(url).read  # rubocop:disable Security/Open
    end
  rescue OpenURI::HTTPError, Errno::ETIMEDOUT, SocketError, Timeout::Error => err
    # #http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
    Rails.logger.warn(err.message)
    debug(err.message)
    nil
  else
    Nokogiri::HTML(html)
  end
end

################
class Parser
  include HttpGet
  include DebugPrint

  def self.parse(*args)
    self.new.parse(*args)
  end

  def initialize(verbose: false)
    @verbose = verbose
  end
end
