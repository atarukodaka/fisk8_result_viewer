module FormHelper
  using SortWithPreset

  def form_group(label, input_tag = nil)
    content_tag(:div, :class => "form-group row") do
      concat(content_tag(:div, label_tag(label), :class => 'col-sm-2'))
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
  def select_tag_with_options(key, *args)
    col =
      case key
      when :category
        Score.uniq_list(:category).sort_with_preset(["MEN", "LADIES", "PAIRS", "ICE DANCE"])
      when :segment
        Score.uniq_list(:segment).sort
      when :nation
        Skater.uniq_list(:nation).sort
      when :competition_type
        Competition.uniq_list(:competition_type).sort
      when :season
        Competition.uniq_list(:season).sort.reverse
      when :element_type
        Element.uniq_list(:element_type).sort
      else
        []
      end
    select_tag(key, options_for_select(col.unshift(nil), selected: params[key]), *args)
  end
  def ajax_search(key, table, search_value: :value)  # TODO
    col_num = table.column_names.index(key.to_s)
    
    "$('##{table.table_id}').DataTable().column(#{col_num}).search(this.#{search_value}).draw();"
  end
end

