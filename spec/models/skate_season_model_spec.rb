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
  end

  describe 'compare' do
    it {
      expect(season > '2016-17').to be true
      expect(season == '2017-18').to be true
      expect(season < '2017-18').to be false
    }
  end
  describe 'minus operator' do
    it {
      expect(season - 1).to eq(SkateSeason.new('2016-17'))
      expect(season - SkateSeason.new('2016-17')).to eq(1)
    }
  end
  describe 'between?' do
    it 'within' do
      expect(season.between?('2012-13', '2018-19')).to be true
      expect(season.between?('2012-13', '2017-18')).to be true
      expect(season.between?('2017-18', '2020-21')).to be true
    end

    it 'out of range' do
      expect(season.between?('2012-13', '2014-15')).to be false
      expect(season.between?('2019-20', '2022-23')).to be false
    end

    it 'from nil' do
      expect(season.between?('2015-16', nil)). to be true
      expect(season.between?('2020-21', nil)). to be false
    end

    it 'to nil' do
      expect(season.between?(nil, '2015-16')). to be false
      expect(season.between?(nil, '2020-21')). to be true
    end

    it 'from nil to nil' do
      expect(season.between?(nil, nil)). to be true
    end
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
