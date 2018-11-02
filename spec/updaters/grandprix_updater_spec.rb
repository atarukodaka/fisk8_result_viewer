require 'rails_helper'
using StringToModel

RSpec.describe GrandprixUpdater, updater: true, vcr: true do
  let(:updater) { GrandprixUpdater.new }

  it {
    season = '2018-19'.to_season
    category = 'MEN'.to_category
    updater.update(season, category)
    expect(GrandprixEvent.count).to eq(6)
  }
end
