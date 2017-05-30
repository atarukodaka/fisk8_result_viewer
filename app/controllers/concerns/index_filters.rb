class IndexFilters
  extend Forwardable
  include Comparable
  include Enumerable
  include ApplicationHelper

  def_delegators :@data, :each, "<=>".to_sym, :keys
  @@select_options = {}
  
  def initialize(hash = {})
    @data = {}
    hash.each do |k, v|
      @data[k] = v
    end
  end
  def filters= (hash)
    @data ||= {}
    hash.each do |k, v|
      @data[k] = v
    end
    self
  end
  def filters
    @data
  end

  def select_options(key, model)
    #model = @data[key][:model]
    @@select_options[key] ||= 
      case key
      when :competition_name, :season
        model.recent.pluck(key).uniq
      when :category
        sort_with_preset(model.pluck(key).uniq,
                         ["MEN", "LADIES", "PAIRS", "ICE DANCE",
                          "JUNIOR MEN", "JUNIOR LADIES", "JUNIOR PAIRS", "JUNIOR ICE DANCE",
                         ])
      when :segment
        sort_with_preset(model.pluck(key).uniq,
                         ["SHORT PROGRAM", "FREE SKATING", "SHORT DANCE", "FREE DANCE"])
      else
        model.pluck(key).sort.uniq
      end.unshift(nil)
  end
  
  ################################################################
  def parse_compare(text)
    method = :eq;
    value = text.to_i
    re = '^ *([=<>]+) *([\d\.\-]+) *$'
    if text =~ /#{re}/
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
    data_to_create = {}
    @data.each do |key, hash|
      if hash[:children]
        hash[:children].each do |ck, ch|
          data_to_create[ck] = ch
        end
      else
        data_to_create[key] = hash
      end
    end
      
    #@data.each do |key, hash|
    data_to_create.each do |key, hash|
      next if (value = params[key]).blank? || hash[:operator].nil?
      next unless model = hash[:model]
      
      case model.columns.find {|c| c.name == key.to_s}.type
      when :boolean
        value = ((value =~ /^true$/i) == 0)
      end

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

  
