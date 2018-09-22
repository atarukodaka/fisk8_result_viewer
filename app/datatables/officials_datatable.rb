class OfficialsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:id])
  end

  def fetch_records
    Official.all
  end
end

  
