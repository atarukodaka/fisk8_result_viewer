require 'rails_helper'

RSpec.describe CompetitionUpdater::Skipper::SeasonSkipper do
  describe 'blank' do
    let (:skipper) { CompetitionUpdater::Skipper::CompetitionUpdater::Skipper::SeasonSkipper.new(nil) }
    it { expect(skipper.skip?('2015')).to be false }
  end

  describe 'just' do
    let (:skipper) { CompetitionUpdater::Skipper::SeasonSkipper.new(2017) }
    it { expect(skipper.skip?(2016)).to be true }
    it { expect(skipper.skip?(2017)).to be false }
    it { expect(skipper.skip?(2018)).to be true }
  end

  describe 'from' do
    let (:skipper) { CompetitionUpdater::Skipper::SeasonSkipper.new(nil, from: 2017) }
    it { expect(skipper.skip?(2016)).to be true }
    it { expect(skipper.skip?(2017)).to be false }
    it { expect(skipper.skip?(2018)).to be false }
  end

  describe 'to' do
    let (:skipper) { CompetitionUpdater::Skipper::SeasonSkipper.new(nil, to: 2017) }
    it { expect(skipper.skip?(2016)).to be false }
    it { expect(skipper.skip?(2017)).to be false }
    it { expect(skipper.skip?(2018)).to be true }
  end

  describe 'from, to' do
    let (:skipper) { CompetitionUpdater::Skipper::SeasonSkipper.new(nil, from: 2015, to: 2017) }
    it { expect(skipper.skip?(2014)).to be true }
    it { expect(skipper.skip?(2015)).to be false }
    it { expect(skipper.skip?(2016)).to be false }
    it { expect(skipper.skip?(2017)).to be false }
    it { expect(skipper.skip?(2018)).to be true }
  end
end
