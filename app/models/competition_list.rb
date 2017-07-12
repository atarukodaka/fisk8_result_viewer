class CompetitionList < ActiveYaml::Base
  # load competition list to update. in default, competitions listed in
  #  'config/competitions.yml' will be load automatically, such as:
  #
  # - http://www.isu.org/compA/result/
  # - http://www.isu.org/compB/result/
  #
  # if specific parser required, write down as hash:
  # -
  #   url: http://www.isu.org/compC/result
  #   parser: :foo
  #
  # if you want to load another list in config/,
  #
  # CompetitionList.set_filename('competition_junior')
  #
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
