require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views
  
  before do
    skater = Skater.create
    comp = Competition.create(cid: "WORLD")
    short = comp.scores.create(sid: "WORLD-SHORT-1", segment: "SHORT", skater: skater)
    short.components.create(number: 1, component: "Skating Skill", value: 10.0)

    free = comp.scores.create(sid: "WORLD-FREE-1", segment: "FREE", skater: skater)
    free.components.create(number: 1, component: "Skating Skill", value: 9.0)
  end
  after do
    Score.all.map(&:destroy)
  end

  describe 'index' do
    it {
      get :index
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('10.0')
    }
    it {
      get :index, params: { segment: "FREE"}
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('9.0')
      expect(response.body).not_to include('10.0')
    }
  end
end
