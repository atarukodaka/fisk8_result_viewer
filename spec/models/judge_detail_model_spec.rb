require 'rails_helper'

RSpec.describe JudgeDetail do
  it {
    competition = create(:competition, :world)
    elem = competition.scores.first.elements.first
    detail = elem.judge_details.create
    expect(detail.detailable_type).to eq("Element")
    expect(detail.detailable).to eq(elem)
  }
  
end
