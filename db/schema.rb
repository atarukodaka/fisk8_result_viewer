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
    t.integer "isu_number"
    t.string "category"
    t.integer "ranking"
    t.float "points"
    t.integer "short_ranking"
    t.integer "free_ranking"
    t.integer "competition_id"
    t.integer "skater_id"
    t.index ["competition_id"], name: "index_category_results_on_competition_id"
    t.index ["skater_id"], name: "index_category_results_on_skater_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.string "short_name"
    t.string "name"
    t.string "city"
    t.string "country"
    t.date "start_date", default: "1970-01-01"
    t.date "end_date", default: "1970-01-01"
    t.string "season"
    t.string "site_url"
    t.string "competition_type"
    t.boolean "isu_championships", default: false, null: false
    t.string "comment"
  end

  create_table "components", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.float "factor"
    t.string "judges"
    t.float "value"
    t.integer "score_id"
    t.index ["score_id"], name: "index_components_on_score_id"
  end

  create_table "elements", force: :cascade do |t|
    t.integer "number"
    t.string "name"
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
    t.string "name"
    t.integer "ranking"
    t.integer "starting_number"
    t.string "category"
    t.string "segment"
    t.date "date", default: "1970-01-01"
    t.string "result_pdf"
    t.float "tss", default: 0.0
    t.float "tes", default: 0.0
    t.float "pcs", default: 0.0
    t.float "deductions", default: 0.0
    t.string "deduction_reasons"
    t.float "base_value", default: 0.0
    t.integer "competition_id"
    t.integer "skater_id"
    t.integer "category_result_id"
    t.index ["category_result_id"], name: "index_scores_on_category_result_id"
    t.index ["competition_id"], name: "index_scores_on_competition_id"
    t.index ["skater_id"], name: "index_scores_on_skater_id"
  end

  create_table "skaters", force: :cascade do |t|
    t.string "name"
    t.string "nation"
    t.string "category"
    t.integer "isu_number"
    t.string "coach"
    t.string "choreographer"
    t.string "birthday"
    t.string "hobbies"
    t.string "height"
    t.string "club"
    t.datetime "bio_updated_at"
  end

end
