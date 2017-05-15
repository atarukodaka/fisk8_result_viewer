class Element < ActiveRecord::Base
  include FilterModules
  
  belongs_to :score
end
