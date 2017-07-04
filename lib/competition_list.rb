class CompetitionList
  DEFAULT_PARSER = :isu_generic
  
  def initialize
    @list = nil
  end

  def load(includes)
    @list ||= includes.unshift(nil).map {|type| load_config(type) }.flatten
  end
  def load_config(type=nil)
    fname = (type) ? "competitions_#{type}.yml" : "competitions.yml"
    yaml_filename = Rails.root.join('config', fname)
    
    YAML.load_file(yaml_filename).map do |item|
      case item
      when String
        {url: item, parser_type: DEFAULT_PARSER, }
      when Hash
        {
          url: item["url"],
          parser_type: item["parser"] || DEFAULT_PARSER,
          comment: item['comment'],
        }
      end
    end
  end

  def create_competitions(last: nil, force: false, accept_categories: nil, includes: [])
    list = load(includes)
    list = list.last(last).reverse if last

    list.each do |item|
      Competition.destroy_existings_by_url(item[:url]) if force
      Competition.create_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment], accept_categories: accept_categories)
    end
  end

  
end
