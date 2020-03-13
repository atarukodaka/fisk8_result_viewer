class CompetitionNormalize < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'competition_normalize'

  #field :regex, default: ''
  #field :competition_class, default: :unknown
  field :competition_type, default: :unknown
#  field :short_name
  field :name

  class << self
    def load_file
      raw_data.map do |k, v|
        { competition_type: k, name: v}
      end
    end
  end

end
