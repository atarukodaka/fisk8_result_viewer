class SkatersDatatable < IndexDatatable
  def initialize
=begin
    rows = Skater.having_scores
    cols =
      [
       {name: "name", filter: ->(r, v){ r.where("name like ?", "%#{v}%") }},
       {name: "category", filter: ->(r, v){ r.where("category like ?", "%#{v}%") }},
       {name: "nation", filter: ->(r, v){ r.where("nation like ?", "%#{v}%") }},
       :isu_number
      ]
=end
    cols = [:name, :category, :nation, :isu_number]
    super(Skater.having_scores, only: cols)
    @settings[:order] = [[cols.index(:category), :asc], [cols.index(:name), :asc]]

    @filters = {
      #name: ->(c, v){ c.where("name like ?", "%#{v}%") },
      name: ->(v){ where("name like ?", "%#{v}%") },
      category: ->(v){ where(category: v) },
      nation: ->(v){ where(nation: v)},
    }
  end
end
