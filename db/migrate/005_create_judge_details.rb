class CreateJudgeDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :panels do |t|
      t.string :name
      t.string :nation
    end

    create_table :officials do |t|
      t.integer :number
      t.belongs_to :panel
      t.belongs_to :performed_segment
    end

    create_table :element_judge_details do |t|
      t.integer :number
      t.float :value

      t.belongs_to :element
      t.belongs_to :panel
    end

    create_table :component_judge_details do |t|
      t.integer :number

      t.float :value

      t.belongs_to :component
      t.belongs_to :panel
    end
  end
end


