class Parser
  include HttpGet
  include DebugPrint

  attr_accessor :verbose

  def initialize(verbose: false, encoding: 'iso-8859-1')
    @verbose = verbose
    @encoding = encoding
  end

  def find_table_rows(page, keyword, type: :equal)
    xpath = Array(keyword).map do |key|
      cond = (type == :equal) ? "text()='#{key}'" : "contains(text(), '#{key}')"
      ["th", "td"].map {|d| "//table//tr//#{d}[#{cond}]/ancestor::table[1]//tr"}
#      ["//table//tr//th[#{cond}]/ancestor::table[1]//tr",
#      "//table//tr//td[#{cond}]/ancestor::table[1]//tr"]
    end.flatten.join(' | ')
    #  xpath = "//table//tr//th[#{cond}] | //table//tr//td[#{cond}]"
    #page.xpath(xpath).xpath('ancestor::table[1]//tr')
    page.xpath(xpath)
  end
end
