require 'rails_helper'
using StringToModel

RSpec.describe Element do
  using StringToModel

  let(:competition) { create(:competition, :world) }

  describe 'single' do
    let(:skater) {
      competition.scores.joins(:category).where("categories.category_type": 'MEN'.to_category_type).first.skater
    }
    let(:score) {
      competition.scores.create(category: 'TEAM MEN'.to_category, segment: 'SHORT PROGRAM'.to_segment,
                                skater: skater)
    }

    describe 'jump' do
      describe 'solo jump' do
        subject { score.elements.create(name: '4T') }
        its(:element_type)  { is_expected.to eq('jump') }
        its(:element_subtype) { is_expected.to eq('solo') }
      end
      describe 'combination jump' do
        subject { score.elements.create(name: '3Lz+3T') }
        its(:element_type)  { is_expected.to eq('jump') }
        its(:element_subtype) { is_expected.to eq('comb') }
      end
    end

    describe 'spin' do
      describe 'combination spin' do
        subject { score.elements.create(name: 'FCCoSp4') }
        its(:element_type) { is_expected.to eq('spin') }
        its(:element_subtype) { is_expected.to eq('comb') }
        its(:level) { is_expected.to eq(4) }
      end
      describe 'unknown' do
        subject { score.elements.create(name: 'AAAAAAASp3') }
        its(:element_subtype)  { is_expected.to be nil }
      end
    end

    describe 'step' do
      subject { score.elements.create(name: 'StSqB') }
      its(:element_type) { is_expected.to eq('step') }
      its(:level) { is_expected.to eq(0) }
    end
    ####
    describe 'unkonwn' do
      subject { score.elements.create(name: 'HogeHogeFoo') }
      its(:element_type) { is_expected.to eq('unknown') }
    end
  end
  ################
  ## ice dance
  describe 'ice dance' do
    let(:skater) { create(:skater, :ice_dance) }
    let(:score) {
      competition.scores.create(category: 'ICE DANCE'.to_category,
                                segment: 'RHYTHM DANCE'.to_segment,
                                skater: skater)
    }
    describe 'patten dance' do
      subject { score.elements.create(name: 'FO') }
      its(:element_type) { is_expected.to eq('pattern_dance') }
      its(:element_subtype) { is_expected.to be nil }
    end

    describe 'unknown' do
      subject { score.elements.create(name: 'FooBAR') }
      its(:element_type) { is_expected.to eq('unknown') }
    end
  end
end
