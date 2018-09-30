module AjaxHelper
  ## customized matches
  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      body = (respond_to? :page) ? page.body : response.body
      body.index(earlier_content.to_s) < body.index(later_content.to_s)
    end
  end

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
      dir = find("#column_#{key}")['class']
      identifers = [main, sub].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
      identifers.reverse! if dir =~ /sorting_desc/
      expect(identifers.first).to appear_before identifers.second
    }
  end

  ####
  def obj_sendkey(obj, key)
    r = obj.send(key)
    (r.respond_to?(:name)) ? r.name : r
  end
  ## filter
  def expect_filter(obj1, obj2, key, column: :name)
    get :list, xhr: true, params: {key => obj_sendkey(obj1, key) }
    expect(response.body).to have_content(obj1.send(column))
    expect(response.body).not_to have_content(obj2.send(column))

    get :list, xhr: true, params: filter_params(key, obj_sendkey(obj1, key))
    expect(response.body).to have_content(obj1.send(column))
    expect(response.body).not_to have_content(obj2.send(column))

    ## only obj2
    get :list, xhr: true, params: {key => obj_sendkey(obj2, key) }
    expect(response.body).not_to have_content(obj1.send(column))
    expect(response.body).to have_content(obj2.send(column))

    get :list, xhr: true, params: filter_params(key, obj_sendkey(obj2, key))
    expect(response.body).not_to have_content(obj1.send(column))
    expect(response.body).to have_content(obj2.send(column))
  end 
  ## order
  def expect_order(obj1, obj2, key, column: :name)
    #names = [obj1, obj2].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(column)}
    names = [obj1, obj2].sort {|a, b| obj_sendkey(a, key) <=> obj_sendkey(b, key)}.map {|d| d.send(column)}
    ## only obj1
    get :list, xhr: true, params: sort_params(key, 'asc')
    expect(names.first).to appear_before(names.last)
    
    get :list, xhr: true, params: sort_params(key, 'desc')
    expect(names.last).to appear_before(names.first)
  end

  ################
  def column_number(column_name)
    controller.create_datatable.column_names.index(column_name.to_s).to_i
  end

  def filter_params(column_name, value)
    {columns: {column_number(column_name).to_s => { data: column_name, "search": {"value": value}}}}
    
  end
  def sort_params(column_name, direction = 'asc')
    {order: {"0": { "column": column_number(column_name), "dir": direction}}}
  end
end


