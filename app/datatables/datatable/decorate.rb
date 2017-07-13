module Datatable::Decorate
  def manipulate_rows(r)
    super(r).decorate
  end
end
