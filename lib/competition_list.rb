class CompetitionList < ActiveHash::Base
  DEFAULT_PARSER = :isu_generic
  
  field :url
  field :parser_type, default: DEFAULT_PARSER
  field :comment
  
  class << self
    def load(includes)
      includes.unshift(nil).map {|type| load_config(type) }.flatten
    end
    def load_config(type=nil)
      fname = (type) ? "competitions_#{type}.yml" : "competitions.yml"
      yaml_filename = Rails.root.join('config', fname)

      YAML.load_file(yaml_filename).each do |item|
        case item
        when String
          #{url: item, parser_type: DEFAULT_PARSER, }
          CompetitionList.create(url: item)
        when Hash
          {
            url: item["url"],
            parser_type: item["parser"] || DEFAULT_PARSER,
            comment: item['comment'],
          }
          CompetitionList.create(url: item['url'], parser_type: item["parser"] || DEFAULT_PARSER, comment: item['commeut'])
        end
      end
    end

    def create_competitions(last: nil, force: false, accept_categories: nil, includes: [])
      load_config
      includes.each {|type| load_config(type) }
      
      list = (last) ? CompetitionList.last(last).reverse : CompetitionList.all
      
      list.each do |item|
        Competition.destroy_existings_by_url(item[:url]) if force
        Competition.create_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment], accept_categories: accept_categories)
      end
    end
  end
  
end
