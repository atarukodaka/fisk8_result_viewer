###############################################################
module AjaxDatatables
  class Datatable
    #
    # class for jquery-datatable. refer 'app/views/application/_datatable.html.slim' as well.
    #
    # in view,
    # = AjaxDatatables::Datatable.new(self).records(User.all).columns([:name, :address]).render
    #
    # for server-side ajax,
    # = AjaxDatatables::Datatable.new(self).ajax(serverside: true, url: users_list_path).render
    #
    # of you can implement your derived class corresponding to controller/model.
    #  class UsersDatatable < AjaxDatatables::Datatable
    #    def initialize(*)
    #      super
    #      columns([:name, :address])
    #      default_orders([[:name, :asc]])
    #    end
    #    def fetch_records
    #      User.all
    #    end
    #  end

    extend Forwardable
    extend Property
    include AjaxDatatables::Datatable::DeferLoadable
    include AjaxDatatables::Datatable::Serversidable
    include AjaxDatatables::Datatable::Decoratable
    include AjaxDatatables::Datatable::Limitable

    def_delegators :@view_context, :params, :link_to, :url_for

    property :data, nil
    property(:records) {  fetch_records() }
    properties :default_orders, default: []
    property(:settings){ default_settings }
    attr_reader :view_context

    def initialize(view_context = nil)
      @view_context = view_context
      yield(self) if block_given?
    end
    ## columns accessors
    def columns(cols=nil)     # cols can be array of Hash or Symbol/String
      if cols                   # setter for method chain
        self.columns = cols
        self 
      else                     # getter
        @columns   
      end
    end
    def columns=(cols) # setter
      @columns = AjaxDatatables::Columns.new(cols, datatable: self)
    end
    ## data fetching/manipulation
    def fetch_records
      []
    end
    def data
      @data ||= manipulate(records)
    end
    def manipulate(r)
      r
    end
    ################
    ## settings, etc
    def default_settings
      {
        processing: true,
        paging: true,
        pageLength: 10,
      }
    end
    def ajax(serverside: false, url: )
      settings.update(serverSide: serverside, ajax: {url: url})
      self
    end
    def column_names
      columns.map(&:name)
    end
    def datatable_attrs
      attrs = settings.merge(
        {
          retrieve: true,
        })
      attrs[:columns] = column_names.map {|name| { data: name, name: name, visible: columns[name].visible, orderable: columns[name].orderable, searchable: columns[name].searchable } }
      attrs
    end
    def attrs
      settings.merge(
        {
          retrieve: true,
          columns: column_names.map {|name|
            {
              data: name, 
              name: name, 
              visible: columns[name].visible, 
              orderable: columns[name].orderable,
              searchable: columns[name].searchable
            }
          },
          order: order,
        })
    end
    def render(partial: "datatable", locals: {})
      @view_context.render(partial: partial, locals: { datatable: self }.merge(locals))
    end
    def table_id
      "table_#{self.object_id}"
    end
    def order
      default_orders.map {|column, dir|
        [column_names.index(column.to_s), dir]
        #["#{column.to_s}:name", dir]
      }
    end
    def view    # short cut for view_context
      @view_context
    end
    ################
    ## format
    def as_json(*args)
      data.map do |item|
        column_names.map do |column_name|
          [column_name, item.try(:send,column_name.to_sym) || item[column_name.to_sym]]
        end.to_h.as_json(*args)
      end
    end
  end
end
## -- end of datatable.rb
