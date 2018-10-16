class SkaterNameCorrection < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'skater_name_correction'

  field :original_name
  field :corrected_name

  class << self
    def correct(name)
      corrected =
        if (item = self.find_by(original_name: name))
          item.corrected_name
        else
          name
        end
      normalize(corrected)
    end
  end
end
