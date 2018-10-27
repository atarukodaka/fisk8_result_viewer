module AjaxFeatureHelper
  SLEEP_COUNT = 0.5
=begin
  shared_examples :contains do |main_flag, sub_flag|
    it {
      if main_flag
        is_expected.to have_content(main.name)
      else
        is_expected.not_to have_content(main.name)
      end
      if sub_flag
        is_expected.to have_content(sub.name)
      else
        is_expected.not_to have_content(sub.name)
      end
    }
  end
=end
  shared_context :contains_all do |datatable|
    it {
      visit datatable_index_path(datatable)
      datatable.data.all.each do |item|
        expect(page.text).to have_content(item.name)
        end
    }
  end
  ## shared functions
  def datatable_index_path(datatable)
    send("#{datatable.default_model.to_s.pluralize.underscore}_path".to_sym)
  end
  
  def ajax_actions(actions, path:, format: :html)
    visit path
    actions.each do |hash|
      key, value, input_type = hash.values_at(:key, :value, :input_type)
      case input_type
      when :fill_in, :text_field
        fill_in key, with: value
        find("input##{key}").send_keys :tab
      when :select
        select value, from: key
      when :click, :checkbox, :button, :submit
        #find(key).click
        find_by_id(key).click
      end
      # sleep 1
      yield if block_given?
    end
    case format
    when :json
      find_by_id('json_button').click
    end

    sleep SLEEP_COUNT
    page
  end
  ################
  module Filter
    #shared_examples :filter do |filter, additional_actions: nil, value_func: nil, pros_func: nil, cons_func: nil|
    shared_examples :filter do |filter, additional_actions: nil, value_func: nil, pros_operator: :eq, cons_operator: :not_eq|
      it {
        datatable = filter.filters.datatable
        column = datatable.columns[filter.key] || next
        value_func ||= lambda {|dt, key| dt.data.first.send(key) }
=begin
        pros_func ||= lambda {|dt, key, value|
          column = dt.columns[key]
          arel = column.table_model.arel_table[column.table_field]
          operator = :eq
          dt.data.where(arel.send(operator, value)).first
          #dt.data.where(dt.columns[key].source => value).first
        }
        cons_func ||= lambda {|dt, key, value|
          column = dt.columns[key]
          arel = column.table_model.arel_table[column.table_field]
          operator = :not_eq
          dt.data.where(arel.send(operator, value)).first
          #dt.data.where.not(dt.columns[key].source => value).first
        }
=end        
        
        value = value_func.call(datatable, filter.key)
        #pros = pros_func.call(datatable, filter.key, value)
        #cons = cons_func.call(datatable, filter.key, value)

        ## pros, cons

        arel = column.table_model.arel_table[column.table_field]
        pros = datatable.data.where(arel.send(pros_operator, value)).first
        cons = datatable.data.where(arel.send(cons_operator, value)).first

        path = datatable_index_path(datatable)
        actions =  [{key: filter.key, input_type: filter.input_type, value: value}]
        actions.push(*additional_actions) if additional_actions

        ajax_actions(actions, path: path)
        expect(page.text).to have_content(pros.name)
        expect(page.text).not_to have_content(cons.name)

        ajax_actions(actions, path: path, format: :json)
        expect(page.text).to have_content(pros.name)
        expect(page.text).not_to have_content(cons.name)
      }
    end
    shared_context :filters do |datatable, excludings: []|
      datatable.filters.map { |filter| filter.children.presence || filter }.flatten
        .reject { |filter| excludings.include?(filter.key) }.each do |filter|
        it_behaves_like :filter, filter
      end
    end

    shared_context :filter_season do | datatable |
      #filter = datatable.filters.map { |filter| filter.children.presence || filter }.flatten.find {|d| d.key == :season}
      filter = datatable.filters.flatten.find {|d| d.key == :season}
      context 'eq season' do
        additional_actions = [{ key: :season_operator, value: '=', input_type: :select }]
        it_behaves_like :filter, filter, additional_actions: additional_actions
      end

      context 'gt season' do
        actions = [{ key: :season_operator, value: '>', input_type: :select }]
        value_func = lambda {|dt, key| dt.data.order("#{dt.columns[key].source} asc").first.send(key) }
        it_behaves_like :filter, filter, additional_actions: actions, value_func: value_func, pros_operator: :gt, cons_operator: :lteq
      end

      context 'lt season' do
        actions = [{ key: :season_operator, value: '<', input_type: :select }]
        value_func = lambda {|dt, key| dt.data.order("#{dt.columns[key].source} desc").first.send(key) }
        it_behaves_like :filter, filter, additional_actions: actions, value_func: value_func, pros_operator: :lt, cons_operator: :gteq
      end

      
=begin
      context 'lteq season' do
        additional_actions = [{ key: :season_operator, value: '>', input_type: :select }]
        it_behaves_like :filter, filter, additional_actions: additional_actions
      end
      context 'gteq season' do
        additional_actions = [{ key: :season_operator, value: '>', input_type: :select }]
        it_behaves_like :filter, filter, additional_actions: additional_actions
      end

      context 'lt season' do
        subject {
          ajax_actions([{ key: :season_operator, value: '<', input_type: :select },
                        { key: :season, value: main.season, input_type: :select }], path: index_path)
        }
        it_behaves_like :contains, false, false
      end
      context 'gt season' do
        subject {
          ajax_actions([{ key: :season_operator, value: '>', input_type: :select },
                        { key: :season, value: main.season, input_type: :select }], path: index_path)
        }
        it_behaves_like :contains, false, true
      end
      context 'lteq season' do
        subject {
          ajax_actions([{ key: :season_operator, value: '<=', input_type: :select },
                        { key: :season, value: main.season, input_type: :select }], path: index_path)
        }
        it_behaves_like :contains, true, false
      end
      context 'gteq season' do
        subject {
          ajax_actions([{ key: :season_operator, value: '>=', input_type: :select },
                        { key: :season, value: main.season, input_type: :select }], path: index_path)
        }
        it_behaves_like :contains, true, true
      end
=end
    end

    ## functions
    def ajax_action_filter(path:, input_type:, key:, value: nil)
      ajax_actions([key: key, value: value, input_type: input_type], path: path)
    end

  end

  ################
  module Order
    RSpec::Matchers.define :appear_before do |later_content|
      match do |earlier_content|
        table_id = find(:css, '.dataTable')[:id]
        table_text = find("##{table_id}").text
        table_text.index(earlier_content.to_s) < table_text.index(later_content.to_s)
      end
    end
=begin
    shared_examples :order_main_sub do |key, identifer_key: :name|
      it {
        table_id = find('.dataTable')[:id]
        dir = find("#column_#{table_id}_#{key}")['class']
        identifers = [main, sub].sort_by { |d| d.send(key) }.map { |d| d.send(identifer_key) }
        identifers.reverse! if dir =~ /sorting_desc/
        expect(identifers.first).to appear_before identifers.second
      }
    end
=end
    ### order
    shared_context :orders do |datatable|
      datatable.columns.select(&:orderable).map(&:name).map(&:to_sym).each do |key|
        it {
          column = datatable.columns[key]
          expected = datatable.data.order("#{column.source} asc").map {|d| d.send(key).to_s}
          raise if expected.count < 2

          ## asc
          visit datatable_index_path(datatable)
          table_id = find('.dataTable')[:id]
          column_id = "column_#{table_id}_#{key}"
          dir = find("#column_#{table_id}_#{key}")['aria-sort']
          find("##{column_id}").click
          sleep SLEEP_COUNT
        
          expected.reverse! if  dir == 'ascending'
          expect(expected.first).to appear_before expected.last

          ## desc
          find("##{column_id}").click
          sleep SLEEP_COUNT
          
          expect(expected.last).to appear_before expected.first
        }
      end
    end
=begin
    shared_context :order do |datatable_class, excludings: []|
      datatable_class.new.columns.select(&:orderable).map(&:name).each do |key|
        next if excludings.include?(key.to_sym)

        include_context :ajax_order, key
      end
    end

    shared_context :ajax_order do |key, identifer_key: :name|
      context key do
        subject! { ajax_action_order(key, path: index_path) }
        it_behaves_like :order_main_sub, key, identifer_key: identifer_key
      end
    end
    ### ajax
    def ajax_action_order(column_name, path:)
      visit path
      table_id = find('.dataTable')[:id]
      column_id = "column_#{table_id}_#{column_name}"

      find("##{column_id}").click
      sleep SLEEP_COUNT
      page
    end
=end
  end
end
