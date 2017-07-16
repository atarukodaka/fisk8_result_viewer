module Datatable::Serverside
  #
  # include (or extend to instance) this module to let it work as server-side datatable.
  # 
  # e.g. if /users/list is called as ajax server-side,
  #
  # class UsersController < ApplicationController
  #   def list
  #     render json: Datatable.new.extend(Datatable::Serverside).set_params(params)
  #   end
  #
  #  note that you need to pass params into the table instance.
  #
  include Datatable::Params
  include Datatable::TableKeys
  include Datatable::Manipulatable
  
  def manipulate(data)
    super(data).where(filter_sql).order(order_sql).page(page).per(per)
    #super(data).page(page).per(per)
  end
  ################
  ## for search
  def filter_sql
    return "" if params[:columns].blank?

    keys = []
    values = []
    params[:columns].each do |num, hash|
      column_name = hash[:data]
      sv = hash[:search][:value].presence || next

      #column = columns.find_by_name(column_name) || raise
      #keys << "#{column.key} like ? "
      #key = @table_keys[column_name.to_sym] || column_name
      key = table_keys(column_name)
      keys << "#{key} like ? "
      values << "%#{sv}%"
    end
    # return such as  ['name like ? and nation like ?', 'foo', 'bar']
    (keys.blank?) ? '' : [keys.join(' and '), *values]
  end
  ################
  ## for sorting
  def order_sql
    return "" if params[:order].blank?

    ary = []
    params[:order].each do |_, hash|   ## params doesnt have map()
      column_name = columns[hash[:column].to_i]
      #ary << [column.key, hash[:dir]].join(' ')
      #key = @table_keys[column_name.to_sym] || column_name
      key = table_keys(column_name)
      ary << [key, hash[:dir]].join(' ')
    end
    ary
  end
  ################
  ## for paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  ################
  ## json output
  def as_json(opts={})
    {
      iTotalRecords: data.model.count,
      iTotalDisplayRecords: data.total_count,
#      data: data.decorate.as_json(only: column_names),
      data: data.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end
end

