class CreateScores < ActiveRecord::Migration[5.1]
  def change
    create_table :scores do |t|
      t.string :name
      t.integer :ranking
      t.integer :starting_number

      t.belongs_to :category
      t.belongs_to :segment
      t.date :date
      t.string :result_pdf

      t.float :tss, default: 0.0
      t.float :tes, default: 0.0
      t.float :pcs, default: 0.0
      t.float :deductions, default: 0.0
      t.string :deduction_reasons
      t.float :base_value, default: 0.0

      t.string :elements_summary
      t.string :components_summary

      t.belongs_to :competition
      t.references :skater
    end

    ################
    create_table :elements do |t|
      t.integer :number
      t.string :name
      t.string :element_type
      t.string :element_subtype
      t.boolean :edgeerror
      t.boolean :underrotated
      t.boolean :downgraded
      t.integer :level
      t.string :info
      t.float :base_value
      t.string :credit
      t.float :goe
      t.string :judges
      t.float :value
      t.float :average

      t.belongs_to :score
    end

    ################
    create_table :components do |t|
      t.integer :number
      t.string :name
      t.float :factor
      t.string :judges
      t.float :value
      t.float :average

      t.belongs_to :score
    end
  end
end
