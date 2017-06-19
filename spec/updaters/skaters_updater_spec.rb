require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'skater', updater: true do
  context 'skaters' do 
    it 'updates skaters' do
      updater = Fisk8ResultViewer::Updater::SkaterUpdater.new(quiet: true)
      updater.update_skaters(categories: [:MEN])
      num_skaters = ::Skater.group(:category).count

      expect(num_skaters["MEN"]).to be > 0
    end
  end
end
