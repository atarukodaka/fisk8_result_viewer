################################################################
module AjaxFeatureHelper
  ## examples
  shared_examples :only_main do
    it {
      is_expected.to have_content(main.name)
      is_expected.not_to have_content(sub.name)
    }
  end
  shared_examples :only_sub do
    it {
      is_expected.not_to have_content(main.name)
      is_expected.to have_content(sub.name)
    }
  end
  shared_examples :both_main_sub do
    it {
      is_expected.to have_content(main.name)
      is_expected.to have_content(sub.name)
    }
  end
  shared_examples :only_earlier do
    it {
      is_expected.to have_content(earlier.name)
      is_expected.not_to have_content(later.name)
    }
  end
  shared_examples :only_later do
    it {
      is_expected.not_to have_content(earlier.name)
      is_expected.to have_content(later.name)
    }
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

  ## context
  shared_context :scores_filter do
    [{ name: :skater_name, input_type: :fill_in, },
     { name: :competition_name, input_type: :fill_in, },
     { name: :competition_class, input_type: :select, },
     { name: :competition_type, input_type: :select, },
     { name: :category_name, input_type: :select, value_function: lambda {|score| score.category_name } },
     { name: :category_type, input_type: :select, },
     { name: :seniority, input_type: :select, },
     { name: :team, input_type: :select, },
     { name: :segment_name, input_type: :select, value_function: lambda {|score| score.segment_name } },
     { name: :segment_type, input_type: :select, },
    ].each do |hash|
      include_context :ajax_filter, hash[:name], hash[:input_type], hash[:value_function]
    end

    include_context :filter_season
  end
  shared_context :filter_season do
    ## main, sub, index_path requried to declair
    let(:later) { (main.season > sub.season) ? main : sub }
    let(:earlier) { (main.season <= sub.season) ? main : sub }

    context 'from later' do
      subject { ajax_action_filter(key: :season_from, value: later.season, input_type: :select, path: index_path) }
      it_behaves_like :only_later
        end
    context 'to earlier' do
      subject { ajax_action_filter(key: :season_to, value: earlier.season, input_type: :select, path: index_path)}
      it_behaves_like :only_earlier
    end
  end

  shared_context :ajax_filter do |key, input_type, value_function|
    context key do
      subject {
        value = (value_function.present?) ? value_function.call(main) : main.send(key)
        ajax_action_filter(key: key, value: value, input_type: input_type, path: index_path)
      }
      it_behaves_like :only_main
    end
  end
  shared_context :ajax_order do |key, identifer_key: :name|
    #let!(:table_id) { visit index_path; find(".dataTable")[:id] }
    context key do
      #subject! { ajax_action(key: "#column_#{table_id}_#{key}", input_type: :click, path: index_path) }
      subject! { ajax_action_order(key, path: index_path) }
      #it { ajax_compare_sorting(main, sub, key: key, identifer_key: identifer_key) }
      it_behaves_like :order_main_sub, key, identifer_key: identifer_key
    end
  end

  ## functions
  def score_filters
  end
  ### ajax
  def ajax_trigger
    page.evaluate_script("$('table.display').trigger('change')")
    sleep 1
  end
  def ajax_action_order(column_name, path: )
    visit path
    table_id = find('.dataTable')[:id]
    column_id = "column_#{table_id}_#{column_name}"
    find("##{column_id}").click
    #ajax_trigger
    sleep 1
    page
  end
  def ajax_action_filter(path:, input_type: , key:, value: nil)
    visit path
    binding.pry    case input_type
    when :fill_in
      fill_in key, with: value
      find("input##{key}").send_keys :tab
    when :select
      select value, from: key
    when :click
      find(key).click
    end
    sleep 1
    # trigger
    #ajax_trigger
    page
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
