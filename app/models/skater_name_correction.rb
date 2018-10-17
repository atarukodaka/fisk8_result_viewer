class SkaterNameCorrection < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'skater_name_correction'

  field :original_name
  field :corrected_name

  class << self
    def load_file
      raw_data.map do |k, v|
        { original_name: k, corrected_name: v }
      end
    end

    def normalize_name(name)
      if name.to_s =~ /^([A-Z\-]+) ([A-Z][A-Za-z].*)$/
        [$2, $1].join(' ')
      else
        name
      end
    end

    def correct(name)
      corrected = self.find_by(original_name: name).try(:corrected_name) || name
      # corrected = (item = self.find_by(original_name: name)) ? item.corrected_name : name
      normalize_name(corrected)
    end
  end
end
