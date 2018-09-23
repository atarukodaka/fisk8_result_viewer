module FormHelper

  def uniq_list(relation, key)
    #@_uniq_list_cache ||= {}
    #@_uniq_list_cache["#{relation.klass.name}-#{key.to_s}"] ||= relation.distinct.pluck(key).compact
    relation.distinct.pluck(key).compact     ## TODO: cache
    
  end

  def form_group(label = nil, input_tag = nil)
    content_tag(:div, :class => "form-group row") do
      label_str = (label.nil?) ? "" : I18n.t("field.#{label}", default: label.to_s)
      concat(content_tag(:div, label_tag(label_str), :class => 'col-sm-2'))
      if block_given?
        concat(content_tag(:div, :class => 'col-sm-10') do
          yield
        end)
      else
        concat(content_tag(:div, input_tag, :class => 'col-sm-10'))
      end
    end
  end
  
  # using SortWithPreset
  def select_tag_with_options(key, *args)
    selected = params[key]

    col =
      case key
      when :category
        uniq_list(Category.order(:id), :name)
      when :category_type
        uniq_list(Category.order(:id), :category_type)
      when :seniority
        uniq_list(Category.order(:id), :seniority)
      when :team
        uniq_list(Category.order(:id), :team)
       when :segment
        uniq_list(Segment.order(:id), :name)
      when :segment_type
        uniq_list(Segment.order(:id), :segment_type)
      when :nation
        uniq_list(Skater, :nation).sort
      when :competition_class
        uniq_list(Competition.all, :competition_class).sort
      when :competition_type
        uniq_list(Competition.all, :competition_type).sort
      when :season
        uniq_list(Competition.all, :season).sort.reverse
      when :element_type
        uniq_list(Element.all, :element_type).sort
      when :element_subtype
        uniq_list(Element.all, :element_subtype).sort
      when :season_from
        uniq_list(Competition.all, :season).sort.reverse
      when :season_to
        uniq_list(Competition.all, :season).sort.reverse
      else
        []
      end
    select_tag(key, options_for_select(col.unshift(nil), selected: selected), *args)
  end
  def ajax_search(key, table, search_value: :value)
    col_num = table.column_names.index(key.to_s)
    "$('##{table.table_id}').DataTable().column(#{col_num}).search(this.#{search_value}).draw();"
  end
  def ajax_draw(table)
    "$('##{table.table_id}').DataTable().draw();"
  end
end

