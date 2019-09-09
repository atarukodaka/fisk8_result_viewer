require 'open-uri'
require 'open_uri_redirections'

module HttpGet
  include DebugPrint

  def get_url(url, encoding: nil)
    mode = encoding ? ['r', encoding].join(':') : 'r'
    #mode = ['r', encoding.to_s].compact.join(':')
    body = open(url, mode).read   # rubocop:disable Security/Open
  rescue OpenURI::HTTPError, Errno::ETIMEDOUT, SocketError, Timeout::Error => e
    #http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
    Rails.logger.warn(e.message)
    debug("#{e.message}: #{url}")
    nil
  else
    #Nokogiri::HTML(body.force_encoding('UTF-8').scrub('?'))
    if encoding.nil?
      det = CharDet.detect(body)
      debug("* charset detected: #{det['encoding']}")
      encoding = det["encoding"] || 'UTF-8'
      encoding = "iso8859-1" if encoding == "TIS-620"  ## TODO: 9088 detected as TIS-620 somehow
      body = body.encode('UTF-8', encoding)
    end
    Nokogiri::HTML(body.to_s.gsub(/&nbsp;?/, ' '))
  end
end
