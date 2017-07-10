class Country < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'city_country_mappings'
end
