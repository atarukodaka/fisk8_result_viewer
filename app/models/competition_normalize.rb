class CompetitionNormalize < ActiveYaml::Base
  set_root_path Rails.root.join('config')
  set_filename 'competition_normalize'

  field :regex, default: ''
  field :name
  field :competition_class, default: :unknown
  field :competition_type, default: :unknown

  class << self
    def load_file
      raw_data.map do |competition_class, v|
        v.map do |competition_type, value|
          hash = {
            competition_class: competition_class,
            competition_type: competition_type,
          }
          case value
          when String
            hash[:regex] = value
          when Hash
            hash.merge!(value.symbolize_keys)
          else
            raise
          end
          hash
        end
      end.flatten
    end ## load file

    def find_match(key)
      self.all.each do |item|
        return item if key.to_s.match?(item.regex)
      end
      nil
    end
  end
end
