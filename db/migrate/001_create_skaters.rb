class CreateSkaters < ActiveRecord::Migration[5.1]
  def change
    create_table :skaters do |t|
      t.string :name
      t.string :nation
      t.string :category
      t.integer :isu_number

    end
  end
end
