module AjaxFeatureHelper
  SLEEP_COUNT = 0.5
  shared_context :contains_all do |datatable|
    context 'contains_all' do
      it {
        visit datatable_index_path(datatable)
        datatable.data.all.each do |item|
          expect(page.text).to have_content(item.name)
        end
      }
    end
  end
  ## shared functions
  def get_datatable(page)   ## ajax
    table_id = page.find(:css, '.dataTable')[:id]
    page.find("##{table_id}")
  end

  def datatable_index_path(datatable)
    send("#{datatable.default_model.to_s.pluralize.underscore}_path".to_sym)
  end

  def ajax_actions(actions, path:, format: :html)  ## ajax
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
        find_by_id(key).click
      end
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
    shared_examples :filter do |filter, additional_actions: nil, value_func: nil, operators: nil|
      it {
        operators ||= { pros: :eq, cons: :not_eq }
        datatable = filter.filters.datatable
        column = datatable.columns[filter.key] || next
        value_func ||= lambda { |dt, key| dt.data.first.send(key) }

        value = value_func.call(datatable, filter.key)

        ## pros, cons
        arel = column.table_model.arel_table[column.table_field]
        pros = datatable.data.where(arel.send(operators[:pros], value))
        cons = datatable.data.where(arel.send(operators[:cons], value))

        path = datatable_index_path(datatable)

        actions = [{ key: filter.key, input_type: filter.input_type, value: value }]
        actions.push(*additional_actions) if additional_actions

        ajax_actions(actions, path: path)
        table_text = get_datatable(page).text

        pros.each { |item| expect(table_text).to have_content(item.name) }
        cons.each { |item| expect(table_text).not_to have_content(item.name) }
        ajax_actions(actions, path: path, format: :json)
        pros.each { |item| expect(page.text).to have_content(item.name) }
        cons.each { |item| expect(page.text).not_to have_content(item.name) }
      }
    end
    shared_context :filters do |datatable|
      context 'filters' do
        datatable.filters.flatten.each do |filter|
          context filter.key do
            it_behaves_like :filter, filter
          end
        end
      end
    end
    shared_context :filter_with_operator do |filter, operator_key, operator_value|
      context "#{operator_key} #{operator_value}" do
        direction, operators =
          case operator_value
          when '>' then [:asc, { pros: :gt, cons: :lteq }]
          when '>=' then [:desc, { pros: :gteq, cons: :lt }]
          when '<' then [:desc, { pros: :lt, cons: :gteq }]
          when '<=' then [:asc, { pros: :lteq, cons: :gt }]
          else raise
          end

        actions = [{ key: operator_key, value: operator_value, input_type: :select }]
        value_func = lambda { |dt, key|
          dt.data.order("#{dt.columns[key].source} #{direction}").first.send(key)
        }
        it_behaves_like :filter, filter, additional_actions: actions, value_func: value_func, operators: operators
      end
    end

    shared_context :filter_season do |datatable|
      filter = datatable.filters.flatten.find { |d| d.key == :season }
      context 'filter_season' do
        include_context :filter_with_operator, filter, :season_operator, '>'
        include_context :filter_with_operator, filter, :season_operator, '<'
      end
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
        table_html = get_datatable(page)['outerHTML']
        table_html.index(earlier_content.to_s) < table_html.index(later_content.to_s)
      end
    end
    ### order
    shared_context :orders do |datatable|
      context :orders do
        datatable.columns.select(&:orderable).map(&:name).map(&:to_sym).each do |key|
          context key do
            it {
              column = datatable.columns[key]
              expected = datatable.data.order("#{column.source} asc").map(&:name)
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
      end
    end
  end
end
################
RSpec.configure do |config|
  config.include AjaxFeatureHelper
  config.include AjaxFeatureHelper::Filter
  config.include AjaxFeatureHelper::Order
end
