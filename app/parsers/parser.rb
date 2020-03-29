class Parser
  include HttpGet
  #include DebugPrint
  include Message

  def find_table_rows(page, keyword, type: :equal)
    xpath = Array(keyword).map do |key|
      cond = (type == :equal) ? "text()='#{key}'" : "contains(text(), '#{key}')"
      #"//table//*[#{cond}]"
      "//table//tr//*[#{cond}]"
      #      ["th", "td"].map {|d| "//table//tr//#{d}//*[#{cond}]" }  #/ancestor::table[1]//tr"}
      #      ["//table//tr//th[#{cond}]/ancestor::table[1]//tr",
      #      "//table//tr//td[#{cond}]/ancestor::table[1]//tr"]
    end.flatten.join(' | ')
    #  xpath = "//table//tr//th[#{cond}] | //table//tr//td[#{cond}]"
    #page.xpath(xpath).xpath('ancestor::table[1]//tr')
    page.xpath(xpath).first&.xpath('ancestor::table[1]/tr')
    # page.xpath(xpath).first&.xpath("../../tr")     ## TODO
  end
end
