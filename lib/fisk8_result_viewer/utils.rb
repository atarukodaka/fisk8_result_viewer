require 'pdftotext'
require 'open-uri'
require 'open_uri_redirections'
#require 'mechanize'

module Fisk8ResultViewer
  module Utils
   
    def logger
      @logger ||= Rails.logger
      #@logger ||= ::Logger.new(STDERR, date_time_format: '%Y-%m-%d %H:%M')
    end

    def get_url(url, read_option: nil)
      begin
        #html = open(url, read_option).read
        html = (read_option) ? open(url, read_option).read : open(url).read
        Nokogiri::HTML(html)
        #p.encoding = 'iso-8859-1'  # for umlaut support
      rescue OpenURI::HTTPError
        logger.warn("!!! HTTP ERror: #{url}")
        nil
      end
    end

    def convert_pdf(url, dir: "./")
      return "" if url.blank?

      ## create dir if not exists
      FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

      ## convert pdf to text
      filename = File.join(dir, URI.parse(url).path.split('/').last)
      open(url, allow_redirections: :safe) do |f|
        File.open(filename, "wb") do |out|
          out.puts f.read
        end
      end
      Pdftotext.text(filename)
    end
    def trim(str)
      str.strip.gsub(/[\r\n]+/, '').gsub(/ +/, ' ')
    end
    def isu_bio_url(isu_number)
      "http://www.isuresults.com/bios/isufs%08d.htm" % [isu_number.to_i]
    end
  end  ## module
end
