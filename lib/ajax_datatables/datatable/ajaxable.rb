module AjaxDatatables::Datatable::Ajaxable
  def table_id
    "table_#{self.object_id}"
  end

  def default_settings
    {
      processing: true,
      paging:     true,
      pageLength: 25,
    }
  end

  def ajax(serverside: false, url:)
    settings.update(serverSide: serverside, ajax: { url: url })
    self
  end

  def as_attrs
    order = default_orders.map { |column, dir|
      [column_names.index(column.to_s), dir]
    }
    settings.merge(
      retrieve: true,
      columns:  column_names.map { |name|
        {
          data:       name,
          name:       name,
          visible:    columns[name].visible,
          orderable:  columns[name].orderable,
          searchable: columns[name].searchable
        }
      },
      order:    order
    )
  end
end

