class CreateCompetitions < ActiveRecord::Migration[5.1]
  def change
    create_table :competitions do |t|
      t.string :cid
      t.string :name
      t.string :city
      t.string :country
      t.date :start_date
      t.date :end_date
      t.string :season
      t.string :site_url
      t.string :competition_type
      #t.string :isu_class
      t.boolean :isu_championships, default: false, null: false
      
      t.string :comment
    end
    
    create_table :category_results do |t|
      t.string :competition_name
      t.string :category

      t.integer :ranking
      t.string :skater_name
      t.string :nation
      t.float :points
      
      t.integer :short_ranking
      t.integer :free_ranking

      t.belongs_to :competition
      t.references :skater
    end
  end
end
