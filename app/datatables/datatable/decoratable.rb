module Datatable::Decoratable
  prepend Datatable::Manipulatable

  def decorate
    add_manipulator(->(r){ r.decorate })
=begin
    instance_eval {
      def manipulator(d)
        super(d).decorate
        self
      end
    }
=end
    self
  end
end  

