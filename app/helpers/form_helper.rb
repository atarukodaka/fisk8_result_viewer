module FormHelper
  def self.cache_uniq_list(cache_name, relation, key)
    @cache ||= {}

    # @cache[cache_name] ||= relation.distinct.pluck(key).compact
    @cache[cache_name] ||= relation.pluck(key).uniq.compact
  end

  def form_group(label = nil, input_tag = nil)
    content_tag(:div, class: 'form-group row') do
      label_str = (label.nil?) ? '' : I18n.t("field.#{label}", default: label.to_s)
      concat(content_tag(:div, label_tag(label_str), class: 'col-sm-2'))
      if block_given?
        concat(content_tag(:div, class: 'col-sm-10') do
          yield
        end)
      else
        concat(content_tag(:div, input_tag, class: 'col-sm-10'))
      end
    end
  end

  def select_tag_with_options(key, *args)
    selected = params[key]
    col =
      case key
      when :category_name, :category_type, :seniority, :team
        FormHelper.cache_uniq_list("category/#{key}", Category.order(:id), key)
      when :segment_name, :segment_type
        FormHelper.cache_uniq_list("segment/#{key}", Segment.order(:id), key)
      when :nation
        FormHelper.cache_uniq_list('skater/nation', Skater.order(:nation), :nation)
      when :competition_class, :competition_type
        FormHelper.cache_uniq_list("competition/#{key}", Competition.all, key).sort
      when :season_from, :season_to, :season
        FormHelper.cache_uniq_list('competition/competition_season', Competition.all, :season).sort.reverse
      when :element_type, :element_subtype
        FormHelper.cache_uniq_list("element/#{key}", Element.all, key).sort
      else
        []
      end
    select_tag(key, options_for_select([nil, col].flatten, selected: selected), *args)
  end

  def ajax_search(key, table, search_value: :value)
    col_num = table.column_names.index(key.to_s)
    "$('##{table.table_id}').DataTable().column(#{col_num}).search(this.#{search_value}).draw();"
  end

  def ajax_draw(table)
    "$('##{table.table_id}').DataTable().draw();"
  end
end
