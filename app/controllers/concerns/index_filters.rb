class IndexFilters
  extend Forwardable
  include Comparable
  include Enumerable  

  def_delegators :@data, :each, "<=>".to_sym
  @@select_options = {}
  
  def initialize(hash = {})
    @data = {}
    hash.each do |k, v|
      @data[k] = v
    end
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

  
