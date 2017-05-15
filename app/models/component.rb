class Component < ActiveRecord::Base
  include FilterModules
  
  belongs_to :score
end

