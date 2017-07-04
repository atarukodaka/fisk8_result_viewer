require 'pdftotext'
require 'open-uri'
require 'open_uri_redirections'

module Utils
=begin
  def logger
    #@logger ||= Rails.logger
    @logger ||= ::Logger.new(STDERR, date_time_format: '%Y-%m-%d %H:%M')
  end
=end
  def get_url(url, read_option: nil)
    html = (read_option) ? open(url, read_option).read : open(url).read
    Nokogiri::HTML(html)
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
=begin
  def str2symbols(str)
    str.split(/ *, */).map(&:to_sym)
  end
=end
end  ## module

