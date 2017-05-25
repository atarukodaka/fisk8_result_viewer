class IndexFilters
  extend ActiveSupport::Concern
  
  extend Forwardable
  include Comparable
  include Enumerable  

  def_delegators :@data, :each, "<=>".to_sym
  @@select_options = {}
  
  def initialize(hash = {})
    @data = Hash.new
    attributes = hash
  end
  def attributes= (hash)
    hash.each do |k, v|
      @data[k] = v
    end
    self
  end

  def method_missing(method, *args)
    @data.send(method, *args)
  end
  def select_options(key)
    @@select_options[key] ||= @data[key][:model].pluck(key).sort.uniq.unshift(nil)
  end

  ################################################################
  def parse_compare(text)
    method = :eq; value = text.to_i
    if text =~ %r{^ *([=<>]+) *([\d\.\-]+) *$}
      value = $2.to_f
      method =
        case $1
        when '='; :eq
        when '>'; :gt
        when '>='; :gteq
        when '<'; :lt
        when '<='; :lteq
        end
    end
    {method: method, value: value}
  end
  def create_arel_tables(params)
    arel_tables = []
    @data.each do |key, hash|
      next if (value = params[key]).blank? || hash[:operator].nil?
      model = hash[:model] || self
      
      case hash[:operator]
      when :like, :match
        arel_tables << model.arel_table[key].matches("%#{value}%")
      when :eq, :is
        arel_tables << model.arel_table[key].eq(value)
      when :compare
        parsed = parse_compare(value)
        #logger.debug("#{value} parsed as '#{parsed[:method]}'")
        arel_tables << model.arel_table[key].method(parsed[:method]).call(parsed[:value]) if parsed[:method]
        
      end
    end
    arel_tables
  end
end
################################################################

module IndexActionModules
  def score_filters
    f = IndexFilters.new
    f.attributes = {
      skater_name: {operator: :like, input: :text_field, model: Score},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},
      season: { operator: :eq, input: :select, model: Competition},
    }
    f
  end

  def filters
    score_filters
  end
  def display_keys
    []
  end

  def decorator
    begin
      "#{controller_name.camelize}ListDecorator".constantize
    rescue NameError
      nil
    end
  end
  def colleciton
  end
  def format_html
    pagination = true
    col = collection.page(params[:page]) if pagination
    
    locals = {
      collection: (decorator) ? decorator.decorate_collection(col) : col,
      filters: filters,
      display_keys: display_keys,
      pagination: pagination,
    }
    render locals: locals
  end

  def format_json
    max_output = 1000
    render json: collection.limit(max_output).select(display_keys) 
  end
  def format_csv
    max_output = 1000
    col = collection.limit(max_output) #.select(display_keys)
    headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
    
    render cvs: "index.csv.ruby", locals: { collection: col, display_keys: display_keys }
  end
  
  def index
    respond_to do |format|
      format.html { format_html }
      format.json { format_json }
      format.csv { format_csv }
    end
  end
end
################################################################
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include IndexActionModules

  ################################################################
  #unless Rails.env.development?
  if Rails.env.production?
    rescue_from Exception, with: :handler_500
    rescue_from ActiveRecord::RecordNotFound, with: :handler_404
    rescue_from ActionController::RoutingError, with: :handler_404
  end

  def handler_404(e = nil)
    respond_to do |format|
      format.html { render 'errors/404', status: :not_found, locals: {message: e.try(:message)}}
      format.json { render json: { error: '404 error'}, status: :not_found }
    end
  end
  
  def handler_500(e = nil)
    respond_to do |format|
      format.html { render 'errors/500', status: :internal_server_error }
      format.json { render json: { error: '500 error'}, status: :internal_server_error, locals: {message: e.try(:message)}}
    end
  end
  
end

