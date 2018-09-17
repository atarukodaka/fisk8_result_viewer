# elements
FactoryBot.define do
  factory :element do
    association :score, factory: :score
    name { "4T" }
    element_type { "jump" }
    value { 10 }
    goe { 2 }
    base_value { 8 }
    judges { "2 2 2" }
    info { "<" }
    credit { "+" }
    number { 1 }
    
    trait :combination do
      name { "4T3T" }
      value { 15 }
      goe { 3 }
      base_value { 12 }
      judges { "3 3 3" }
      number { 2 }
    end

    trait :spin do
      association :score, factory: [:score, :finlandia]
      name { "LSp4" }
      value { 2 }
      goe { -1 }
      base_value { 3 }
      judges { "-1 -1 -1" }
      info { "" }
      credit { "" }
      number { 3 }
    end
  end
end

