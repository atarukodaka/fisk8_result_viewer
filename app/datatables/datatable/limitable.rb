module Datatable::Limitable
  def limit(n=5_000)
    @limit = n
    self.extend Datatable::Limit
  end
end

module Datatable::Limit
  def manipulate(r)
    super(r).limit(@limit).offset(params[:offset].to_i || 0)
  end
end
