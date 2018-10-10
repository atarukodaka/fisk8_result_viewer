require 'rails_helper'

RSpec.describe SkateSeason do
  let(:season) { SkateSeason.new('2017-18') }

  describe 'initialize' do
    it { expect(SkateSeason.new('2017-18')).to eq(season)    }
    it { expect(SkateSeason.new('2017-09-01')).to eq(season)    }
    it { expect(SkateSeason.new(Date.new(2017, 9, 1))).to eq(season)    }
  end

  describe 'attributes' do
    it { expect(season.to_s).to eq('2017-18')    }
    it { expect(season.start_date).to eq(Date.new(2017, 7, 1))    }
    it { expect(season.year).to eq(2017)    }
  end

  describe 'between?' do
    it {
      ## withtin
      expect(season.between?('2012-13', '2018-19')).to be true
      expect(season.between?('2012-13', '2017-18')).to be true
      expect(season.between?('2017-18', '2020-21')).to be true

      ## out of range
      expect(season.between?('2012-13', '2014-15')).to be false
      expect(season.between?('2019-20', '2022-23')).to be false
    }
  end

  describe 'compare' do
    it {
      after = SkateSeason.new('2018-19')
      expect(season < after).to be true
    }
    it {
      before = SkateSeason.new('2014-15')
      expect(season > before).to be true
    }
    it {
      same = SkateSeason.new('2017-18')
      expect(season == same).to be true
    }
  end
end
