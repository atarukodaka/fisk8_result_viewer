require 'rails_helper'

RSpec.describe Competition do
  describe 'normalization' do
    it {
      comp = Competition.create(name: "")
      expect(comp.competition_class).to eq('unknown')
    }

    it {
      CompetitionNormalize.create(regex: "^ISU World", competition_class: "isu", competition_type: "world",
                                  short_name: "WORLD%{year}", name: "ISU World Figure Skating %{year}")
      comp = Competition.create(name: "ISU World", start_date: '2017-7-1')
      expect(comp.competition_class).to eq('isu')
      expect(comp.competition_type).to eq('world')
      expect(comp.short_name).to eq('WORLD2017')
      expect(comp.name).to eq('ISU World Figure Skating 2017')
    }
  end
end
