module Property
  # Instance Property class
  #
  #   class Foo
  #     property :bar, 0
  #     property :baz
  #   end
  #   foo = Foo.new
  #   foo.bar #{ => 0 }
  #   foo.bar(1).baz([:a])  #{ => obj }  // method chain
  #
  #   foo.bar = 3  #{ => 3 }

  ## foo.bar = 3
  def define_setter(sym)
    define_method("#{sym}=") do |*args|
      variable_name = "@#{sym.to_sym}"

      instance_variable_set(variable_name, args.first)
    end
  end

  ## foo.update_foo(bar: 3)
  def define_updater(sym)
    define_method("update_#{sym}") do |*args|
      variable_name = "@#{sym.to_sym}"

      value = instance_variable_get(variable_name) || {}
      value.update(*args)
      instance_variable_set(variable_name, value)
      self
    end
  end

=begin
  ## foo.add_foo(3)
  def define_adder(sym)
    define_method("add_#{sym}") do |*args|
      variable_name = "@#{sym.to_sym}"
      value = instance_variable_get(variable_name) || []
      value << [*args]
      instance_variable_set(variable_name, value.flatten)
      self
    end
  end
=end
  ################
  def property(sym, default = nil, &initializer)
    initializer ||= ->(*) { default }

    ## define getter and setter with method change
    define_method(sym) do |*args|
      variable_name = "@#{sym.to_sym}"

      if !args.empty? # set value and return self for method chain
        instance_variable_set variable_name, args.first  ##  unless readonly
        self
      elsif !instance_variable_defined?(variable_name)  ##  && !readonly # set default value if undef
        instance_variable_set(variable_name, instance_eval(&initializer))
      else
        instance_variable_get(variable_name)
      end
    end

    define_setter(sym)
    define_updater(sym)
    # define_adder(sym)
  end

  def properties(*syms, default: nil, &initializer)
    [*syms].flatten.each { |sym| property sym, default, &initializer }
  end
end
