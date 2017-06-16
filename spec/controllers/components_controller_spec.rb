require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views
  
  before do
    skater = Skater.create
    comp = Competition.create(short_name: "WORLD")
    short = comp.scores.create(name: "WORLD-SHORT-1", segment: "SHORT", skater: skater)
    short.components.create(number: 1, name: "Skating Skill", value: 10.0)
    free = comp.scores.create(name: "WORLD-FREE-1", segment: "FREE", skater: skater)
    free.components.create(number: 1, name: "Skating Skill", value: 9.0)
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
    # compare
    it {
      get :index, params: { value: "9.5", value_operator: '<'}
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('9.0')
      expect(response.body).not_to include('10.0')
    }
    it {
      get :index, params: { value: "9", value_operator: '<='}
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('9.0')
      expect(response.body).not_to include('10.0')
    }
    it {
      get :index, params: { value: "9", value_operator: '>='}
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('9.0')
      expect(response.body).to include('10.0')
    }
    it {
      get :index, params: { value: "9", value_operator: '='}
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('9.0')
      expect(response.body).not_to include('10.0')
    }
    
  end
end
