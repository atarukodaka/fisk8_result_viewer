module CompetitionUpdater::Utils
  using StringToModel

=begin
  def slice_common_attributes(model, hash)
    hash.slice(*model.class.column_names.map(&:to_sym) & hash.keys)
  end
=end
  def find_or_create_skater(isu_number, skater_name, nation, cat)
    category = (cat.class == String) ? cat.to_category : cat
    normalized = normalize_persons_name(skater_name)
    @skater_name_correction ||= YAML.load_file(Rails.root.join('config', 'skater_name_correction.yml'))
    corrected_skater_name = @skater_name_correction[normalized] || normalized
    ActiveRecord::Base.transaction do
      Skater.find_or_create_by_isu_number_or_name(isu_number, corrected_skater_name) do |sk|
        sk.attributes = {
          category: Category.where(team: false, category_type: category.category_type).first,
          nation:   nation,
        }
      end
    end
  end

  def normalize_persons_name(name)
    if name.to_s =~ /^([A-Z\-]+) ([A-Z][A-Za-z].*)$/
      [$2, $1].join(' ')
    else
      name
    end
  end
end
