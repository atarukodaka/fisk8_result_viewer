require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe Skater, updater: true do
  describe 'update skaters' do
    before(:all) {
      SkaterUpdater.new.update_skaters
    }
    # [:MEN, :LADIES, :PAIRS, :"ICE DANCE"].each do |category_str|
    Category.having_isu_bio.each do |category|
      context "\# of skater in '#{category.name}'" do
        it { expect(Skater.where(category: category).count).to be > 0 }
      end
    end
  end
  describe 'skater detail' do
    it {
      isu_number = 10967 ## Yuzuru HANYU
      SkaterUpdater.new(verbose: true).update_skater_detail(isu_number)
      skater = Skater.find_by(isu_number: isu_number)
      expect(skater.coach).not_to be_nil
    }
  end
end
