class CompetitionNormalize < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'competition_normalize'

  field :regex, default: ''
  field :competition_class, default: :unknow
  field :competition_type, default: :unknow
  field :short_name
  field :name

  class << self
    def load_file
      raw_data.map do |key, array|
        { regex: key, competition_class: array[0], competition_type: array[1],
          short_name: array[2], name: array[3] }
      end
    end
  end
end
