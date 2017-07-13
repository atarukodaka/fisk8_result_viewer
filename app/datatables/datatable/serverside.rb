module Datatable::Serverside
  #
  # include (or extend to instance) this module to work as server-side datatable.
  # 
  # e.g. if /users/list is called as ajax server-side,
  #
  # class UsersController < ApplicationController
  #   def list
  #     render json: Datatable.new.extend(Datatable::Serverside).tap {|t| t.params = params}
  #   end
  #
  #  note that you need to pass params into the table instance.
  #
  include Datatable::Params

  def manipulate_rows(rws)
    super(rws).where(filter_sql).order(order_sql).page(page).per(per)
  end
  def filter_sql
    return "" if params[:columns].blank?

    keys = []
    values = []
    params[:columns].each do |num, hash|
      column_name = hash[:data]
      sv = hash[:search][:value].presence || next
      column = columns.find_by_name(column_name) || raise
      keys << "#{column.key} like ? "
      values << "%#{sv}%"
    end
    if keys.blank?
      ""
    else
      [keys.join(' and '), *values]
    end
  end
  ## for sorting
  def order_sql
    return "" if params[:order].blank?

    ary = []
    params[:order].each do |_, hash|  # TODO: each for columns
      column = columns[hash[:column].to_i]
      ary << [column.key, hash[:dir]].join(' ')
    end
    ary
  end
  ## for paging
  def page
    params[:start].to_i / per + 1
  end
  def per
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
  
  def as_json(opts={})
    {
      iTotalRecords: rows.model.count,
      iTotalDisplayRecords: rows.total_count,
      data: rows.decorate.map {|item|
        column_names.map {|c| [c, item.send(c)]}.to_h
      }
    }
  end
end

