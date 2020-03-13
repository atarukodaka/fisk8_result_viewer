class CompetitionClass < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'competition_class'

  field :regex, default: ''
  field :competition_class, default: :unknown
  field :competition_type, default: :unknown

  class << self
    def load_file
      raw_data.map do |competition_class, v|
        v.map do |competition_type, regex|
          {
            competition_class: competition_class,
            competition_type: competition_type,
            regex: regex,
          }
        end
      end.flatten
    end
  end
end
