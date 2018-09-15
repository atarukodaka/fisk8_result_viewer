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
    end
  end
  
  # using SortWithPreset
  def select_tag_with_options(key, *args)
    selected = params[key]

    col =
      case key
      when :category
        Category.order(:id).uniq_list(:name)
      when :category_type
        Category.order(:id).uniq_list(:category_type)
      when :seniority
        Category.order(:id).uniq_list(:seniority)
      when :team
        Category.order(:id).uniq_list(:team)
      when :segment
        Segment.order(:id).uniq_list(:name)
      when :segment_type
        Segment.order(:id).uniq_list(:segment_type)
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

