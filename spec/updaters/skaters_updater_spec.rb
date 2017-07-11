require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'update skaters', updater: true do
  it 'updates skaters' do
    Category.update_skaters
    num_skaters = Skater.group(:category).count
    
    expect(num_skaters["MEN"]).to be > 0
    expect(num_skaters["LADIES"]).to be > 0
    expect(num_skaters["PAIRS"]).to be > 0
    expect(num_skaters["ICE DANCE"]).to be > 0        
  end
end
