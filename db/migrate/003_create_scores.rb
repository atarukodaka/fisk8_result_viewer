class CreateScores < ActiveRecord::Migration[5.1]
  def change
    create_table :scores do |t|
      t.string :sid
      t.string :skater_name
      t.integer :ranking
      t.integer :starting_number
      t.string :nation

      t.string :competition_name
      t.string :category
      t.string :segment
      t.date :date, default: Time.new(1970, 1, 1, 0, 0, 0)
      t.string :result_pdf
      
      t.float :tss
      t.float :tes
      t.float :pcs
      t.float :deductions
      t.string :deduction_reasons
      t.float :base_value
      t.string :elements_summary
      t.string :components_summary

      t.belongs_to :competition
      t.references :skater
      t.references :category_result
    end

    create_table :elements do |t|
      t.integer :number
      t.string :name
      t.string :info
      t.float :base_value
      t.string :credit
      t.float :goe
      t.string :judges
      t.float :value

      t.belongs_to :score
    end

    create_table :components do |t|
      t.integer :number
      t.string :name
      t.float :factor
      t.string :judges
      t.float :value

      t.belongs_to :score
    end
  end
end
