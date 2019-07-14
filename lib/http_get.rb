require 'open-uri'
require 'open_uri_redirections'

module HttpGet
  include DebugPrint

  def get_url(url, encoding: nil)
    mode = encoding ? ['r', encoding].join(':') : 'r'
    body = open(url, mode).read   # rubocop:disable Security/Open
  rescue OpenURI::HTTPError, Errno::ETIMEDOUT, SocketError, Timeout::Error => e
    #http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
    Rails.logger.warn(e.message)
    debug("#{e.message}: #{url}")
    nil
  else
    Nokogiri::HTML(body)
  end
end
