require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe Skater, updater: true do
  describe 'update skaters' do
    before(:all) {
      SkaterUpdater.new.update_skaters
    }
    [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category_str|
      context "\# of skater in '#{category_str}'" do
        it { expect(Skater.where(category: Category.find_by(name: category_str)).count).to be > 0 }
      end
    end
  end
  describe 'skater detail' do
    it {
      isu_number = 10967    ## Yuzuru HANYU
      SkaterUpdater.new(verbose: true).update_skater_detail(isu_number)
      skater = Skater.find_by(isu_number: isu_number)
      expect(skater.coach).not_to be_nil
    }
  end
end
