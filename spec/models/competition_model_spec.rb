require 'rails_helper'

=begin
RSpec.describe Competition do
  describe 'normalization' do
    it {
      comp = Competition.create(short_name: 'FOOOOTESTDUMMY', start_date: Time.zone.today)
      expect(comp.competition_class).to eq('unknown')
    }

    it {
      CompetitionNormalize.create(regex: '^WC[0-9]', competition_class: 'isu', competition_type: 'world',
                                  name: 'ISU World Figure Skating %{year}')
      comp = Competition.create(short_name: 'WC2017', start_date: '2017-7-1')
      expect(comp.competition_class).to eq('isu')
      expect(comp.competition_type).to eq('wc')
      expect(comp.name).to eq('ISU World Figure Skating 2017')
    }
  end
end
=end
