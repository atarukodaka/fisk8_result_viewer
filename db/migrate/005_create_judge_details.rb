class CreateJudgeDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :panels do |t|
      t.string :name
      t.string :nation
    end
    create_table :element_judge_details do |t|
      t.string :panel_name
      t.string :panel_nation
      t.integer :number

      t.float :value

      t.belongs_to :element
    end

    create_table :component_judge_details do |t|
      t.string :panel_name
      t.string :panel_nation
      t.integer :number

      t.float :value

      t.belongs_to :component
    end

  end
end


