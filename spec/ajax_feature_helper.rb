################################################################
module AjaxFeatureHelper
  ## examples
  shared_examples :contains do |main_flag, sub_flag|
    if main_flag
      it { is_expected.to have_content(main.name) }
    else
      it { is_expected.not_to have_content(main.name) }
    end
    if sub_flag
      it { is_expected.to have_content(sub.name) }
    else
      it { is_expected.not_to have_content(sub.name) }
    end
  end

  ################
  module Filter
    ## context
    shared_context :filter do |filters|
      filters.each do |hash|
        include_context :ajax_filter, hash[:name], hash[:input_type]
      end
    end

    shared_context :filter_season do
      context :from_later do
        subject { ajax_action_filter(key: :season_from, value: sub.season, input_type: :select, path: index_path) }
        it_behaves_like :contains, false, true
      end
      
      context :to_earlier do
        subject { ajax_action_filter(key: :season_to, value: main.season, input_type: :select, path: index_path) }
        it_behaves_like :contains, true, false
      end
    end
    shared_context :ajax_filter do |key, input_type|
      context key do
        subject {
          #value = (value_function.present?) ? value_function.call(main) : main.send(key)
          value = main.send(key)
          ajax_action_filter(key: key, value: value, input_type: input_type, path: index_path)
        }
        it_behaves_like :contains, true, false
      end
    end

    ## functions
    def ajax_action_filter(path:, input_type: , key:, value: nil)
      visit path
      case input_type
      when :fill_in
        fill_in key, with: value
        find("input##{key}").send_keys :tab
      when :select
        select value, from: key
      when :click
        find(key).click
      end
      sleep 1
      page
    end

    ################
    shared_context :score_filter do
      include_context :filter, [
                        { name: :skater_name, input_type: :fill_in, },
                        { name: :competition_name, input_type: :fill_in, },
                        { name: :competition_class, input_type: :select, },
                        { name: :competition_type, input_type: :select, },
                        { name: :category_name, input_type: :select },
                        { name: :category_type, input_type: :select, },
                        { name: :seniority, input_type: :select, },
                        { name: :team, input_type: :select, },
                        { name: :segment_name, input_type: :select },
                        { name: :segment_type, input_type: :select, },
                      ]      
    end
  end

  ################
  module Order
    RSpec::Matchers.define :appear_before do |later_content|
      match do |earlier_content|
      body = (respond_to? :page) ? page.body : response.body
      body.index(earlier_content.to_s) < body.index(later_content.to_s)
      end
    end

    shared_examples :order_main_sub do |key, identifer_key: :name|
      it {
        table_id = find('.dataTable')[:id]
        dir = find("#column_#{table_id}_#{key}")['class']
        identifers = [main, sub].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
        identifers.reverse! if dir =~ /sorting_desc/
        expect(identifers.first).to appear_before identifers.second
      }
    end
    ### order
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
    def ajax_action_order(column_name, path: )
      visit path
      table_id = find('.dataTable')[:id]
      column_id = "column_#{table_id}_#{column_name}"

      find("##{column_id}").click
      sleep 1
      page
    end
  end
=begin
  def ajax_compare_sorting(obj1, obj2, key:, identifer_key: :name)
    dir = find("#column_#{key}")['class']
    identifers = [obj1, obj2].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
    identifers.reverse! if dir =~ /sorting_desc/
    #expect(page.body.index(identifers.first)).to be < page.body.index(identifers.second)
    expect(identifers.first).to appear_before identifers.second
  end
=end
end
