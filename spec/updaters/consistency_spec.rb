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
end

