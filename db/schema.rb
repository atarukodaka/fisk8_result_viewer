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
    t.string "category_type"
    t.string "isu_bio_url"
  end

  create_table "category_results", force: :cascade do |t|
    t.integer "category_id"
    t.integer "ranking"
    t.float "points"
    t.integer "short_ranking"
    t.integer "free_ranking"
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

  create_table "competitions", force: :cascade do |t|
    t.string "short_name"
    t.string "name"
    t.string "city"
    t.string "country"
    t.string "timezone", default: "UTC"
    t.date "start_date", default: "1970-01-01"
    t.date "end_date", default: "1970-01-01"
    t.string "season"
    t.string "site_url"
    t.string "competition_type"
    t.string "competition_class"
    t.string "parser_type", default: "isu_generic"
    t.string "comment"
  end

  create_table "component_judge_details", force: :cascade do |t|
    t.integer "number"
    t.float "value"
    t.float "average"
    t.integer "component_id"
    t.integer "panel_id"
    t.index ["component_id"], name: "index_component_judge_details_on_component_id"
    t.index ["panel_id"], name: "index_component_judge_details_on_panel_id"
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

  create_table "element_judge_details", force: :cascade do |t|
    t.integer "number"
    t.float "value"
    t.float "average"
    t.integer "element_id"
    t.integer "panel_id"
    t.index ["element_id"], name: "index_element_judge_details_on_element_id"
    t.index ["panel_id"], name: "index_element_judge_details_on_panel_id"
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
    t.integer "score_id"
    t.index ["score_id"], name: "index_elements_on_score_id"
  end

  create_table "officials", force: :cascade do |t|
    t.integer "number"
    t.integer "panel_id"
    t.integer "performed_segment_id"
    t.index ["panel_id"], name: "index_officials_on_panel_id"
    t.index ["performed_segment_id"], name: "index_officials_on_performed_segment_id"
  end

  create_table "panels", force: :cascade do |t|
    t.string "name"
    t.string "nation"
  end

  create_table "performed_segments", force: :cascade do |t|
    t.integer "category_id"
    t.integer "segment_id"
    t.datetime "starting_time", default: "1969-12-31 15:00:00"
    t.integer "judge01_id"
    t.integer "judge02_id"
    t.integer "judge03_id"
    t.integer "judge04_id"
    t.integer "judge05_id"
    t.integer "judge06_id"
    t.integer "judge07_id"
    t.integer "judge08_id"
    t.integer "judge09_id"
    t.integer "judge10_id"
    t.integer "judge11_id"
    t.integer "judge12_id"
    t.integer "competition_id"
    t.index ["category_id"], name: "index_performed_segments_on_category_id"
    t.index ["competition_id"], name: "index_performed_segments_on_competition_id"
    t.index ["judge01_id"], name: "index_performed_segments_on_judge01_id"
    t.index ["judge02_id"], name: "index_performed_segments_on_judge02_id"
    t.index ["judge03_id"], name: "index_performed_segments_on_judge03_id"
    t.index ["judge04_id"], name: "index_performed_segments_on_judge04_id"
    t.index ["judge05_id"], name: "index_performed_segments_on_judge05_id"
    t.index ["judge06_id"], name: "index_performed_segments_on_judge06_id"
    t.index ["judge07_id"], name: "index_performed_segments_on_judge07_id"
    t.index ["judge08_id"], name: "index_performed_segments_on_judge08_id"
    t.index ["judge09_id"], name: "index_performed_segments_on_judge09_id"
    t.index ["judge10_id"], name: "index_performed_segments_on_judge10_id"
    t.index ["judge11_id"], name: "index_performed_segments_on_judge11_id"
    t.index ["judge12_id"], name: "index_performed_segments_on_judge12_id"
    t.index ["segment_id"], name: "index_performed_segments_on_segment_id"
  end

  create_table "scores", force: :cascade do |t|
    t.string "name"
    t.integer "ranking"
    t.integer "starting_number"
    t.integer "category_id"
    t.integer "segment_id"
    t.date "date", default: "1970-01-01"
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
    t.integer "category_result_id"
    t.index ["category_id"], name: "index_scores_on_category_id"
    t.index ["category_result_id"], name: "index_scores_on_category_result_id"
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
    t.integer "category_id"
    t.integer "isu_number"
    t.string "coach"
    t.string "choreographer"
    t.date "birthday"
    t.string "hobbies"
    t.string "hometown"
    t.string "height"
    t.string "club"
    t.datetime "bio_updated_at"
    t.index ["category_id"], name: "index_skaters_on_category_id"
  end

end
