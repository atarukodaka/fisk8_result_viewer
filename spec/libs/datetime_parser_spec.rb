require 'rails_helper'

RSpec.describe DatetimeParser do
  describe 'mdformat' do
    describe 'd/m/y' do
      subject { DatetimeParser.parse('20/3/2019 0:0:0') }
      it { is_expected.to eq(Time.new(2019, 3, 20).in_time_zone('UTC')) }
    end
    describe 'd.m.y' do
      subject { DatetimeParser.parse('20.3.2019 0:0:0') }
      it { is_expected.to eq(Time.new(2019, 3, 20).in_time_zone('UTC')) }
    end

    describe 'd/m/y or m/d/y' do
      subject { DatetimeParser.parse('2/3/2019 0:0:0') }
      it { is_expected.to eq(Time.new(2019, 3, 2).in_time_zone('UTC')) }
    end

    describe 'm/d/y' do
      subject { DatetimeParser.parse('3/20/2019 0:0:0') }
      it { is_expected.to eq(Time.new(2019, 3, 20).in_time_zone('UTC')) }
    end
    describe 'm.d.y' do
      subject { DatetimeParser.parse('3.20.2019 0:0:0') }
      it { is_expected.to eq(Time.new(2019, 3, 20).in_time_zone('UTC')) }
    end
  end

  describe 'within' do
    it {
      t1 = DatetimeParser.parse('1/3/2019 0:0:0')
      t2 = DatetimeParser.parse('20/3/2019 0:0:0')

      expect(DatetimeParser.within_days?([t1, t2], days: 30)).to be_truthy
    }
    it {
      t1 = DatetimeParser.parse('1/3/2019 0:0:0')
      t2 = DatetimeParser.parse('20/4/2019 0:0:0')

      expect(DatetimeParser.within_days?([t1, t2], days: 30)).to be_falsey
    }
  end
end
