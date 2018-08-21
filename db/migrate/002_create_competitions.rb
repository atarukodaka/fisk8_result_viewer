class CreateCompetitions < ActiveRecord::Migration[5.1]
  def change
    ################
    # competitions
    create_table :competitions do |t|
      t.string :short_name
      t.string :name
      t.string :city
      t.string :country
      t.string :timezone, default: "UTC"
      t.date :start_date, default: Date.new(1970, 1, 1)
      t.date :end_date, default: Date.new(1970, 1, 1)
      t.string :season
      t.string :site_url
      t.string :competition_type
      t.string :competition_class
      #t.boolean :isu_championships, default: false, null: false
      t.string :parser_type, default: "isu_generic"
      
      t.string :comment
    end

    ################
    # results
    create_table :results do |t|
      #t.integer :isu_number   # TODO: ?? required ?
      t.string :category
      t.integer :ranking
      t.float :points

      ## short
      t.integer :short_ranking
=begin
      t.float :short_tss
      t.float :short_tes
      t.float :short_pcs
      t.integer :short_deductions
      t.float :short_bv
=end
      ## free
      t.integer :free_ranking
=begin      
      t.float :free_tss
      t.float :free_tes
      t.float :free_pcs
      t.integer :free_deductions
      t.float :free_bv

      ## total
      t.float :total_bv
      t.float :total_goe
=end
      ## relations
      t.belongs_to :competition
      t.references :skater
    end
  end
end
