module Datatable::Limitable
  def limit(n=10_000)
    @limit = n
    self.extend Datatable::Limit
  end
end

module Datatable::Limit
  def decorate(r)
    super(r).limit(@limit)
  end
end
