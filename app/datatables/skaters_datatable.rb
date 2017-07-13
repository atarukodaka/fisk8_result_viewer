class SkatersDatatable < IndexDatatable
  def initialize
    rows = Skater.having_scores
    cols =
      [
       {name: "name", filter: ->(r, v){ r.where("name like ?", "%#{v}%") }},
       {name: "category", filter: ->(r, v){ r.where("category like ?", "%#{v}%") }},
       {name: "nation", filter: ->(r, v){ r.where("nation like ?", "%#{v}%") }},
       :isu_number
      ]
    super(rows, cols)

    @order = [[:name, :asc]]    
  end
end
