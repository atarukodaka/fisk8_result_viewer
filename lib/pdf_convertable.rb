require 'pdftotext'
require 'tempfile'

module PdfConvertable
  def convert_pdf(url)
    return nil if url.blank?

    begin
      open(url, allow_redirections: :safe) do |f|
        tmp_filename = "tmp.pdf"
        Tempfile.create(tmp_filename) do |out|
          out.binmode
          out.write f.read

          Pdftotext.text(out.path)
        end
      end
    rescue OpenURI::HTTPError
      logger.warn("HTTP Error: #{url}")
      return nil
    end
  end
=begin
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
=end
end
