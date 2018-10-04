class CreateCategoriesSegments < ActiveRecord::Migration[5.1]
  def change
    ################
    create_table :categories do |t|
      t.string :name
      t.string :abbr
      t.string :seniority
      #t.boolean :indivisual
      t.boolean :team
      t.string :category_type
      t.string :isu_bio_url
    end

    ################
    create_table :segments do |t|
      t.string :name
      t.string :abbr
      t.string :segment_type
    end
  end
end
