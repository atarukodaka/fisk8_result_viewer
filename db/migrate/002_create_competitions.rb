class CreateCompetitions < ActiveRecord::Migration[5.1]
  def change
    ################
    # competitions
    create_table :competitions do |t|
      t.string :short_name
      t.string :name
      t.string :city
      t.string :country
      t.string :timezone, default: 'UTC'
      t.date :start_date   # , default: Date.new(1970, 1, 1)
      t.date :end_date     # , default: Date.new(1970, 1, 1)
      t.string :season
      t.string :site_url
      t.string :competition_type
      t.string :competition_class
      # t.string :parser_type, default: 'isu_generic'

      t.string :comment
    end

    ################
    # category results
    create_table :category_results do |t|
      t.belongs_to :category
      t.integer :ranking
      t.float :points

      t.integer :short_ranking
      t.integer :free_ranking

      ## relations
      t.belongs_to :competition
      t.references :skater
      t.references :short
      t.references :free
    end

    ################
    # performed segments
    create_table :performed_segments do |t|
      t.belongs_to :category
      t.belongs_to :segment
      t.datetime :starting_time   # , default: Time.zone.local(1970, 1, 1, 0, 0, 0)

      ## relations
      t.belongs_to :competition
    end
  end
end
