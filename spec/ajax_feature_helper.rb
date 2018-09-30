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
      table_id = find(".dataTable")[:id]
      dir = find("#column_#{table_id}_#{key}")['class']
      identifers = [main, sub].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
      identifers.reverse! if dir =~ /sorting_desc/
      expect(identifers.first).to appear_before identifers.second
    }
  end

  ## context
  shared_context :filter_season do
    ## main, sub, index_path requried to declair
    let(:later) { (main.season > sub.season) ? main : sub }
    let(:earlier) { (main.season <= sub.season) ? main : sub }
    
    context "from later" do
      subject { ajax_action_filter(key: :season_from, value: later.season, input_type: :select, path: index_path) }
      it_behaves_like :only_later
        end
    context "to earlier" do
      subject { ajax_action_filter(key: :season_to, value: earlier.season, input_type: :select, path: index_path)}
      it_behaves_like :only_earlier
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
  def ajax_trigger
    page.evaluate_script("$('table.display').trigger('change')")
    sleep 1
    binding.pry
  end
  def ajax_action_order(column_name, path: )
    visit path
    table_id = find(".dataTable")[:id]
    column_id = "column_#{table_id}_#{column_name}"
    find("##{column_id}").click
    ajax_trigger
    page
  end
  def ajax_action_filter(path:, input_type: , key:, value: nil)
    visit path
    case input_type
    when :fill_in
      fill_in key, with: value
    when :select
      select value, from: key
    when :click
      find(key).click
    end
    # trigger
    ajax_trigger
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
