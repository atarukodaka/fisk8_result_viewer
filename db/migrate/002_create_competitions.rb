class CreateCompetitions < ActiveRecord::Migration[5.1]
  def change
    ################
    # competitions
    create_table :competitions do |t|
      t.string :key
      t.string :name
      t.string :city
      t.string :country
      t.string :timezone, default: 'UTC'
      t.date :start_date
      t.date :end_date
      t.string :season
      t.string :site_url
      t.string :competition_type
      t.string :competition_class
      t.string :comment

      t.timestamps
    end

    ################
    # category results
    create_table :category_results do |t|
      t.belongs_to :category
      t.integer :ranking
      t.float :points

      t.integer :short_ranking
      t.float :short_tss
      t.float :short_tes
      t.float :short_pcs
      t.float :short_deductions

      t.integer :free_ranking
      t.float :free_tss
      t.float :free_tes
      t.float :free_pcs
      t.float :free_deductions

      ## relations
      t.belongs_to :competition
      t.references :skater
      t.references :short
      t.references :free
    end

    ################
    # time schedule
    create_table :time_schedules do |t|
      t.belongs_to :competition
      t.belongs_to :category
      t.belongs_to :segment
      t.datetime :starting_time
    end
  end
end
