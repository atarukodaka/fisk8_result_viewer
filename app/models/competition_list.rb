class CompetitionList < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'competitions'

  DEFAULT_PARSER = :isu_generic
  
  field :url
  field :parser_type, default: DEFAULT_PARSER
  field :comment
  
  class << self
    def load_file
      raw_data.map do |item|
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
  end
end
