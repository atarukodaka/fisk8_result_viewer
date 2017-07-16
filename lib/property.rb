module Property
  def property(sym, default = nil)
    define_method(sym) do |*args|
      variable_name = "@#{sym.to_sym}"

      if args.present?    # set value and return self for method chain
        instance_variable_set variable_name, args.first
        self
      else   # get value
        if !instance_variable_defined?(variable_name) # default value if undef yet
          instance_variable_set(variable_name, default)
        else
          instance_variable_get(variable_name)
        end
      end
    end

    define_method("#{sym}=") do |*args|
      variable_name = "@#{sym.to_sym}"
      
      instance_variable_set(variable_name, args.first)
    end

    ## update_* methods for hash
    define_method("update_#{sym}") do |*args|
      variable_name = "@#{sym.to_sym}"
      
      value = instance_variable_get(variable_name) || {}  # TODO: check if hash
      value.update(*args)
      instance_variable_set(variable_name, value)
      self
    end

    define_method("add_#{sym}") do |*args|
      variable_name = "@#{sym.to_sym}"
      value = instance_variable_get(variable_name) || {}  # TODO: check if array
      value << args.first
      instance_variable_set(variable_name, value)
      self
    end
  end
  def properties(*syms)
    [*syms].flatten.each {|sym| property sym }
  end
end

=begin
require "instance_property/version"

module InstanceProperty
  def property(sym, default = nil, &initializer)
      initializer ||= -> * { default }

      define_method(sym) do |*args|
        name = "@#{sym}".to_sym

        if !args.empty?
          instance_variable_set name, args.first
        elsif !instance_variable_defined? name
          instance_variable_set name, instance_eval(&initializer)
        end

        instance_variable_get name
      end
  end

  def properties(sym0, *syms, &initializer)
    ([sym0] + syms).each {|sym| property sym, &initializer }
  end
end
=end