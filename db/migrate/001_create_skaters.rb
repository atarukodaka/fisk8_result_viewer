class CreateSkaters < ActiveRecord::Migration[5.1]
  def change
    create_table :skaters do |t|
      t.string :name
      t.string :nation
      # t.string :category
      t.belongs_to :category
      t.integer :isu_number

      t.string :coach
      t.string :choreographer
      t.date :birthday
      t.string :hobbies
      t.string :hometown
      t.string :height
      t.string :club

      t.timestamp :bio_updated_at
    end
  end
end
