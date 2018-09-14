module FormHelper
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
      #concat(yield) if block_given?
    end
  end
  
  # using SortWithPreset
  def select_tag_with_options(key, *args)
    col =
      case key
      when :category
      #Category.all.map(&:name) & Score.uniq_list(:category)
        Category.all.map(&:name)
      when :segment
      #Score.uniq_list(:segment).sort
        Segment.uniq_list(:name).sort
      when :segment_type
      #Score.uniq_list(:segment_type).sort
        Segment.uniq_list(:segment_type).sort
      when :nation
        Skater.uniq_list(:nation).sort
      when :competition_class
        Competition.uniq_list(:competition_class).sort
      when :competition_type
        Competition.uniq_list(:competition_type).sort
      when :season
        Competition.uniq_list(:season).sort.reverse
      when :element_type
        Element.uniq_list(:element_type).sort
      when :element_subtype
        Element.uniq_list(:element_subtype).sort
      else
        []
      end
    select_tag(key, options_for_select(col.unshift(nil), selected: params[key]), *args)
  end
  def ajax_search(key, table, search_value: :value)
    col_num = table.column_names.index(key.to_s)
    "$('##{table.table_id}').DataTable().column(#{col_num}).search(this.#{search_value}).draw();"
  end
  def ajax_draw(table)
    "$('##{table.table_id}').DataTable().draw();"
    #"$('##{table.table_id}').DataTable().columns().search().draw();"
  end
end

