require 'rails_helper'

#describe ApiSkatersController, type: :controller do
RSpec.describe 'api routings', type: :routing do
  it 'skaters' do
    expect(get('/api/skaters')).to route_to(controller: "api/skaters", action: "index", format: "json")
    expect(get('/api/skaters/1')).to route_to(controller: "api/skaters", action: "show", format: "json", isu_number: "1")
  end
  it 'competitions' do
    expect(get('/api/competitions')).to route_to(controller: "api/competitions", action: "index", format: "json")
    expect(get('/api/competitions/WORLD2017')).to route_to(controller: "api/competitions", action: "show", format: "json", short_name: "WORLD2017")
  end
  it 'scores' do
    expect(get('/api/scores')).to route_to(controller: "api/scores", action: "index", format: "json")
    expect(get('/api/scores/WORLD2017-M-S-1')).to route_to(controller: "api/scores", action: "show", format: "json", name: "WORLD2017-M-S-1")
  end
  it 'elements' do
    expect(get('/api/elements')).to route_to(controller: "api/elements", action: "index", format: "json")
  end
  it 'components' do
    expect(get('/api/components')).to route_to(controller: "api/components", action: "index", format: "json")
  end
  
end

  
