require 'rails_helper'

RSpec.describe Deviation, type: :competition_updater, updater: true do
  let(:site_url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
  let(:competition_updater) { CompetitionUpdater.new }
  let(:deviation_updater) { DeviationsUpdater.new }

  it {
    competition_updater.update_competition(site_url, enable_judge_details: true)
    deviation_updater.update_deviations
  }
end
