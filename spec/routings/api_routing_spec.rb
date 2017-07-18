require 'rails_helper'

RSpec.describe 'api routings', type: :routing do
  describe Api::SkatersController do
    it {
      expect(get('/api/skaters')).to route_to(controller: "api/skaters", action: "index", format: "json")
    }
    it {
      expect(get('/api/skaters/1')).to route_to(controller: "api/skaters", action: "show", format: "json", isu_number: "1")
    }
  end
  ################
  describe Api::CompetitionsController do
    it {
      expect(get('/api/competitions')).to route_to(controller: "api/competitions", action: "index", format: "json")
    }
    it {
      expect(get('/api/competitions/WORLD2017')).to route_to(controller: "api/competitions", action: "show", format: "json", short_name: "WORLD2017")
    }
  end
  ################
  describe Api::ResultsController do
    it {
      expect(get('/api/results')).to route_to(controller: "api/results", action: "index", format: "json")
    }
    
  end
  ################
  describe Api::ScoresController do
    it {
      expect(get('/api/scores')).to route_to(controller: "api/scores", action: "index", format: "json")
    }
    it {
      expect(get('/api/scores/WORLD2017-M-S-1')).to route_to(controller: "api/scores", action: "show", format: "json", name: "WORLD2017-M-S-1")
    }
  end
  ################
  describe Api::ElementsController do
    it {
      expect(get('/api/elements')).to route_to(controller: "api/elements", action: "index", format: "json")
    }
  end
  describe Api::ComponentsController do
    it {
      expect(get('/api/components')).to route_to(controller: "api/components", action: "index", format: "json")
    }
  end
end

  
