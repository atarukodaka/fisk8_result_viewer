require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe Skater, updater: true do
  before(:all) {
    SkaterUpdater.new.update_skaters
  }
  [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category_str|
    context "\# of skater in '#{category_str}'" do
      it { expect(Skater.where(category: Category.find_by(name: category_str)).count).to be > 0 }
    end
  end
end
