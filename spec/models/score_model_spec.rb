require 'rails_helper'

RSpec.describe Score do
  describe 'having_scores' do
    it {
      create(:competition, :world)
      create(:competition, :finlandia)

      expect(Skater.having_scores.count).to eq(2)
    }
  end
  describe 'find' do
    it {
      create(:skater, :men)
      expect(Skater.find_skater_by(isu_number: 1, name: nil).isu_number).to eq(1)
      expect(Skater.find_skater_by(isu_number: nil, name: 'Taro YAMADA').isu_number).to eq(1)
      expect(Skater.find_skater_by(isu_number: 999, name: 'Foo BAR')).to be nil
    }
  end
end
