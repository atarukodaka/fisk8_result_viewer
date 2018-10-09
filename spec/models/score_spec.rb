require 'rails_helper'

RSpec.describe Score do
  describe 'having_scores' do
    it {
      world = create(:competition, :world)
      finlandia = create(:competition, :finlandia)

      expect(Skater.having_scores.count).to eq(2)
    }
  end
  describe 'find' do
    it {
      create(:skater, :men)
      expect(Skater.find_by_isu_number_or_name(1, nil).isu_number).to eq(1)
      expect(Skater.find_by_isu_number_or_name(nil, 'Taro YAMADA').isu_number).to eq(1)
    }
  end
end

