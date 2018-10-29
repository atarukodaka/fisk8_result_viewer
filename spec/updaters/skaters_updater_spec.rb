require 'rails_helper'
using StringToModel

RSpec.describe SkaterUpdater, updater: true do
  let(:updater) { SkaterUpdater.new(verbose: false) }
  
  describe 'update skaters' do
    before(:all) {
      updater.new.update_skaters
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
      updater.new.update_skater_detail(isu_number)
      skater = Skater.find_by(isu_number: isu_number)
      expect(skater.coach).not_to be_nil
    }
  end
  
  describe 'skaters detail' do
    it {
      men = 'MEN'.to_category_type
      Skater.create(name: 'Yuzuru HANYU', isu_number: 10_967, category_type: men)
      Skater.create(name: 'Shoma UNO', isu_number: 12_455, category_type: men)
      updater.update_skaters_detail
      expect(Skater.find_by(isu_number: 10967).hometown).to eq('Sendai')
      expect(Skater.find_by(isu_number: 12455).hometown).to eq('Nagoya')
    }
  end
end
