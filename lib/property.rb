module Property
  # Instance Property class
  #
  #   class Foo
  #     property :bar, 0
  #     property, :baz
  #   end
  #   foo = Foo.new
  #   foo.bar #{ => 0 }
  #   foo.bar(1).baz([:a])  #{ => obj }  // method chain
  #
  #   foo.bar = 3  #{ => 3 }

  def property(sym, default = nil, &initializer)   # TODO: readonly
    initializer ||= -> * { default }
    
    ## define getter and setter with method change
    define_method(sym) do |*args|
      variable_name = "@#{sym.to_sym}"

      #if !args.empty?    # set value and return self for method chain
      if args.present?  # TODO: not depend on activesupport
        instance_variable_set variable_name, args.first
        self
      else   # get value
        if !instance_variable_defined?(variable_name) # set default value if undef
          instance_variable_set(variable_name, instance_eval(&initializer))
        else
          instance_variable_get(variable_name)
        end
      end
    end
    ## define setter
    define_method("#{sym}=") do |*args|
      variable_name = "@#{sym.to_sym}"
      
      instance_variable_set(variable_name, args.first)
    end

    ## define updater for hash
    define_method("update_#{sym}") do |*args|
      variable_name = "@#{sym.to_sym}"
      
      value = instance_variable_get(variable_name) || {}  # TODO: check if hash
      value.update(*args)
      instance_variable_set(variable_name, value)
      self
    end

    ## define adder for array
    define_method("add_#{sym}") do |*args|
      variable_name = "@#{sym.to_sym}"
      value = instance_variable_get(variable_name) || []  # TODO: check if array
      value << [*args]
      instance_variable_set(variable_name, value.flatten)
      self
    end
  end
  def properties(*syms, default: nil, &initializer)
    [*syms].flatten.each {|sym| property sym, default, &initializer }
  end
end
