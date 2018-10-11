class CompetitionNormalize < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'competition_normalize'

  field :regex, default: ''
  field :competition_class, default: :unknown
  field :competition_type, default: :unknown
  field :short_name
  field :name
end
