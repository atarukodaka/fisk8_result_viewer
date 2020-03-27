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

ActiveRecord::Schema.define(version: 5) do

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.string "seniority"
    t.boolean "team"
    t.integer "category_type_id"
    t.string "isu_bio_url"
    t.index ["category_type_id"], name: "index_categories_on_category_type_id"
  end

  create_table "category_results", force: :cascade do |t|
    t.integer "category_id"
    t.integer "ranking"
    t.float "points"
    t.integer "short_ranking"
    t.float "short_tss"
    t.float "short_tes"
    t.float "short_pcs"
    t.float "short_deductions"
    t.integer "free_ranking"
    t.float "free_tss"
    t.float "free_tes"
    t.float "free_pcs"
    t.float "free_deductions"
    t.integer "competition_id"
    t.integer "skater_id"
    t.integer "short_id"
    t.integer "free_id"
    t.index ["category_id"], name: "index_category_results_on_category_id"
    t.index ["competition_id"], name: "index_category_results_on_competition_id"
    t.index ["free_id"], name: "index_category_results_on_free_id"
    t.index ["short_id"], name: "index_category_results_on_short_id"
    t.index ["skater_id"], name: "index_category_results_on_skater_id"
  end

  create_table "category_types", force: :cascade do |t|
    t.string "name"
    t.string "isu_bio_url"
  end

  create_table "competitions", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.string "city"
    t.string "country"
    t.string "timezone", default: "UTC"
    t.date "start_date"
    t.date "end_date"
    t.string "season"
    t.string "site_url"
    t.string "competition_type"
    t.string "competition_class"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "components", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.float "factor"
    t.string "judges"
    t.float "value"
    t.float "average"
    t.integer "score_id"
    t.index ["score_id"], name: "index_components_on_score_id"
  end

  create_table "deviations", force: :cascade do |t|
    t.string "name"
    t.integer "score_id"
    t.integer "official_id"
    t.float "tes_deviation"
    t.float "tes_deviation_ratio"
    t.float "pcs_deviation"
    t.float "pcs_deviation_ratio"
    t.index ["official_id"], name: "index_deviations_on_official_id"
    t.index ["score_id"], name: "index_deviations_on_score_id"
  end

  create_table "elements", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "element_type"
    t.string "element_subtype"
    t.boolean "edgeerror"
    t.boolean "underrotated"
    t.boolean "downgraded"
    t.integer "level"
    t.string "info"
    t.float "base_value"
    t.string "credit"
    t.float "goe"
    t.string "judges"
    t.float "value"
    t.float "average"
    t.integer "score_id"
    t.index ["score_id"], name: "index_elements_on_score_id"
  end

  create_table "judge_details", force: :cascade do |t|
    t.integer "number"
    t.float "value"
    t.float "deviation"
    t.string "detailable_type"
    t.integer "detailable_id"
    t.integer "official_id"
    t.index ["detailable_type", "detailable_id"], name: "index_judge_details_on_detailable_type_and_detailable_id"
    t.index ["official_id"], name: "index_judge_details_on_official_id"
  end

  create_table "officials", force: :cascade do |t|
    t.string "function_type"
    t.string "function"
    t.integer "number"
    t.integer "panel_id"
    t.integer "competition_id"
    t.integer "category_id"
    t.integer "segment_id"
    t.index ["category_id"], name: "index_officials_on_category_id"
    t.index ["competition_id"], name: "index_officials_on_competition_id"
    t.index ["panel_id"], name: "index_officials_on_panel_id"
    t.index ["segment_id"], name: "index_officials_on_segment_id"
  end

  create_table "panels", force: :cascade do |t|
    t.string "name"
    t.string "nation"
  end

  create_table "scores", force: :cascade do |t|
    t.string "name"
    t.integer "ranking"
    t.integer "starting_number"
    t.integer "category_id"
    t.integer "segment_id"
    t.date "date"
    t.string "result_pdf"
    t.float "tss", default: 0.0
    t.float "tes", default: 0.0
    t.float "pcs", default: 0.0
    t.float "deductions", default: 0.0
    t.string "deduction_reasons"
    t.float "base_value", default: 0.0
    t.string "elements_summary"
    t.string "components_summary"
    t.integer "competition_id"
    t.integer "skater_id"
    t.index ["category_id"], name: "index_scores_on_category_id"
    t.index ["competition_id"], name: "index_scores_on_competition_id"
    t.index ["segment_id"], name: "index_scores_on_segment_id"
    t.index ["skater_id"], name: "index_scores_on_skater_id"
  end

  create_table "segments", force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.string "segment_type"
  end

  create_table "skaters", force: :cascade do |t|
    t.string "name"
    t.string "nation"
    t.integer "category_type_id"
    t.integer "isu_number"
    t.string "coach"
    t.string "choreographer"
    t.date "birthday"
    t.string "hobbies"
    t.string "hometown"
    t.string "height"
    t.string "club"
    t.string "practice_low_season"
    t.string "practice_high_season"
    t.datetime "bio_updated_at"
    t.index ["category_type_id"], name: "index_skaters_on_category_type_id"
  end

  create_table "time_schedules", force: :cascade do |t|
    t.integer "competition_id"
    t.integer "category_id"
    t.integer "segment_id"
    t.datetime "starting_time"
    t.index ["category_id"], name: "index_time_schedules_on_category_id"
    t.index ["competition_id"], name: "index_time_schedules_on_competition_id"
    t.index ["segment_id"], name: "index_time_schedules_on_segment_id"
  end

end
