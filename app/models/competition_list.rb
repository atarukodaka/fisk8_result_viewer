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

  field :url
  field :parser_type # , default: CompetitionParser::DEFAULT_PARSER
  field :comment

  class << self
    def load_file
      ## ruby2.5, rails5.2.6: hash key needs to be string.
      raw_data.map do |item|
        hash = {}
        case item
        when String
          hash['site_url'] = item
        when Hash
          hash = item
        end
        hash
      end
    end
  end
end
