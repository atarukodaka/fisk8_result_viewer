FactoryBot.define do
  factory :component do
    trait :ss do
      number { 1 }
      name { 'Skating Skills' }
      factor { 1.0 }
      value  { 10.0 }
      judges { '10 10 10 ' }
    end

    trait :tr do
      number { 2 }
      name { 'Transitions' }
      factor { 1.8 }
      value  { 9.0 }
      judges { '9 9 9 ' }
    end
  end
end
