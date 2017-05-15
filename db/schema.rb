# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 3) do

  create_table "category_results", force: :cascade do |t|
    t.string "category"
    t.integer "ranking"
    t.string "skater_name"
    t.string "nation"
    t.float "points"
    t.integer "short_ranking"
    t.integer "free_ranking"
    t.integer "competition_id"
    t.integer "skater_id"
    t.index ["competition_id"], name: "index_category_results_on_competition_id"
    t.index ["skater_id"], name: "index_category_results_on_skater_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.string "cid"
    t.string "name"
    t.string "city"
    t.string "country"
    t.date "start_date"
    t.date "end_date"
    t.string "site_url"
    t.string "competition_type"
    t.string "season"
  end

  create_table "components", force: :cascade do |t|
    t.integer "number"
    t.string "component"
    t.float "factor"
    t.string "judges"
    t.float "value"
    t.integer "score_id"
    t.index ["score_id"], name: "index_components_on_score_id"
  end

  create_table "elements", force: :cascade do |t|
    t.integer "number"
    t.string "element"
    t.string "info"
    t.float "base_value"
    t.string "credit"
    t.float "goe"
    t.string "judges"
    t.float "value"
    t.integer "score_id"
    t.index ["score_id"], name: "index_elements_on_score_id"
  end

  create_table "scores", force: :cascade do |t|
    t.string "sid"
    t.string "skater_name"
    t.integer "ranking"
    t.integer "starting_number"
    t.string "nation"
    t.string "competition_name"
    t.string "category"
    t.string "segment"
    t.date "date"
    t.string "result_pdf"
    t.float "tss"
    t.float "tes"
    t.float "pcs"
    t.float "deductions"
    t.string "elements_summary"
    t.string "components_summary"
    t.integer "competition_id"
    t.integer "skater_id"
    t.index ["competition_id"], name: "index_scores_on_competition_id"
    t.index ["skater_id"], name: "index_scores_on_skater_id"
  end

  create_table "skaters", force: :cascade do |t|
    t.string "name"
    t.string "nation"
    t.string "category"
    t.integer "isu_number"
  end

end
