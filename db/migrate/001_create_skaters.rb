class CreateSkaters < ActiveRecord::Migration[5.1]
  def change
    create_table :skaters do |t|
      t.string :name
      t.string :nation
      t.references :category_type
      t.integer :isu_number

      t.string :coach
      t.string :choreographer
      t.date :birthday
      t.string :hobbies
      t.string :hometown
      t.string :height
      t.string :club

      t.string :practice_low_season
      t.string :practice_high_season

      t.timestamp :bio_updated_at
    end
  end
end
