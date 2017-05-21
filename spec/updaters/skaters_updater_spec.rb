require 'rails_helper'
require 'fisk8viewer'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'skater', updater: true do
  describe 'update skaters' do 
    it {
      updater = Fisk8Viewer::Updater::SkatersUpdater.new
      updater.update_skaters([:MEN])
      #skater = Skater.find_by(isu_number: 10967)
      #updater.update_isu_bio_details(skater)
      num_skaters = Skater.group(:category).count

      expect(num_skaters["MEN"]).to be > 0
    }
  end
end
