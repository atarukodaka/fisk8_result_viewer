class CreateJudgeDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :panels do |t|
      t.string :name
      t.string :nation
    end

    create_table :officials do |t|
      t.integer :number
      t.boolean :absence, default: false
      t.belongs_to :panel
      t.belongs_to :performed_segment
    end

    create_table :element_judge_details do |t|
      t.integer :number
      t.float :value
      t.float :average
      t.float :deviation
      t.float :abs_deviation
      
      t.belongs_to :element
      t.belongs_to :official
    end

    create_table :component_judge_details do |t|
      t.integer :number
      t.float :value
      t.float :average
      t.float :deviation

      t.belongs_to :component
      t.belongs_to :official
    end

    ################
    create_table :deviations do |t|
      t.belongs_to :score
      #t.belongs_to :panel
      t.belongs_to :official
      
      t.float :tes_deviation
      t.float :tes_deviation_ratio
      t.float :pcs_deviation
      t.float :pcs_deviation_ratio
      #t.integer :num_elements  ## TODO: necessary ?
    end
  end  ## change
end

