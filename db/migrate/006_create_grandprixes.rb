class CreateGrandprixes < ActiveRecord::Migration[5.1]
  def change
    create_table :grandprix_events do |t|
      t.string :name
      t.integer :number
      t.string :season
      t.belongs_to :category
      t.boolean :done
    end

    create_table :grandprix_entries do |t|
      t.integer :ranking
      t.belongs_to :skater
      t.belongs_to :grandprix_event
      t.integer :point, default: 0
    end
  end
end
