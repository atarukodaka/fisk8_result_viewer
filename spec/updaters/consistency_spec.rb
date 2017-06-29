require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding consistency: true
end

RSpec.describe 'database consistency', consistency: true do
  before do
    env = :development
    ActiveRecord::Base.establish_connection(env)
  end
  it 'tss = tes + pcs + deductions' do
    Score.all.each do |score|
      expect(score.tss).to be_within(0.001).of(score.tes + score.pcs + score.deductions)
      expect(score.base_value).to be_within(0.001).of(score.elements.sum(:base_value))
      expect(score.tes).to be_within(0.001).of(score.elements.sum(:value))
    end
  end
  it 'competition short name uniq' do
    count = Competition.count
    uniq_short_name_count = Competition.distinct.pluck(:short_name).count
    expect(count).to eq(uniq_short_name_count)
  end
  it 'score name uniq' do
    count = Score.count
    uniq_name_count = Score.distinct.pluck(:name).count
    expect(count).to eq(uniq_name_count)
  end
end

