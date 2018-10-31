require 'open-uri'
require 'open_uri_redirections'

module HttpGet
  include DebugPrint

  def get_url(url, mode: 'r')
    body = open(url, mode).read   # rubocop:disable Security/Open
  rescue OpenURI::HTTPError, Errno::ETIMEDOUT, SocketError, Timeout::Error => err
    #http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
    Rails.logger.warn(err.message)
    debug("#{err.message}: #{url}")
    nil
  else
    Nokogiri::HTML(body)
  end
end
