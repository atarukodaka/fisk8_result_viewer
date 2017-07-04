require 'pdftotext'

module PdfConvertable
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
end
