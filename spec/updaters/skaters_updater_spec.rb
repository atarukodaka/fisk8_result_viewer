require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe Skater, updater: true do
  before(:all) {
    SkaterUpdater.new.update_skaters
  }
  [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category|
    context "\# of skater in '#{category}'" do
      it { expect(Skater.where(category: category).count).to be > 0 }
    end
  end
end
