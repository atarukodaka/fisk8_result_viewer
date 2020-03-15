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
  #   parser_type: :gpjpn
  #
  # if you want to load another list in config/,
  #
  # CompetitionList.set_filename('competition_junior')
  #
  set_root_path Rails.root.join('config')
  set_filename 'competitions'

=begin
  field :site_url
  field :parser_type
  field :comment
  field :name
  field :country
  field :city
  # field :date_format
=end

  class << self
    DEFAULT_KEY = 'site_url'.freeze

    def load_file
      ## ruby2.5, rails5.2.6: hash key needs to be string.
      data = raw_data.map do |key, value|
        hash = { 'short_name' => key }
        case value
        when String
          hash[DEFAULT_KEY] = value
        when Hash
          hash.merge!(value)
        end
        hash
      end
      data
=begin
      raw_data.map do |item|
        hash = {}
        case item
        when String
          hash[DEFAULT_KEY] = item
        when Hash
          hash = item
        end
        hash
      end
=end
    end
  end  ## class
end
