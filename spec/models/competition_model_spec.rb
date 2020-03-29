require 'rails_helper'

RSpec.describe Competition do
  describe 'normalization' do
    describe 'unknown' do
      subject { Competition.create(key: 'FOOOOTESTDUMMY', start_date: Time.zone.today) }
      its(:competition_class) { is_expected.to eq('unknown') }
    end

    describe 'normalize name, class, type' do
      subject {
        CompetitionNormalize.create(regex: '^ZZZWC[0-9]', competition_class: 'zzzisu', competition_subclass: 'zzzworld', name: 'ZZZ ISU World Figure Skating %{year}')
        Competition.create(key: 'ZZZWC2017', start_date: '2017-7-1')
      }
      its(:competition_class) { is_expected.to eq('zzzisu') }
      its(:competition_subclass) { is_expected.to eq('zzzworld') }
      its(:name) { is_expected.to eq('ZZZ ISU World Figure Skating 2017') }
    end

    describe 'no key' do
      subject { Competition.create(name: 'Foo Skating') }
      its(:key) { is_expected.to eq('FOO_SKATING') }
    end
  end
end
