require 'rails_helper'

RSpec.describe SkaterUpdater, updater: true do
  describe 'update skaters' do
    before(:all) {
      SkaterUpdater.new.update_skaters
    }
    CategoryType.all.each do |category_type|
      context "\# of skater in '#{category_type.name}'" do
        it { expect(Skater.where(category_type: category_type).count).to be > 0 }
      end
    end
  end
  describe 'skater detail' do
    it {
      isu_number = 10_967 ## Yuzuru HANYU
      SkaterUpdater.new(verbose: true).update_skater_detail(isu_number)
      skater = Skater.find_by(isu_number: isu_number)
      expect(skater.coach).not_to be_nil
    }
  end
end
