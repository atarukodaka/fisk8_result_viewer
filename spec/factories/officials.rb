FactoryBot.define do
  factory :official do
    trait :first do
      number { 1 }
      panel { create(:panel, :john) }
    end

    trait :second do
      number { 2 }
      panel { create(:panel, :mike) }
    end
  end

  factory :panel do
    trait :john do
      name { "John FOO" }
      nation { "USA" }
    end

    trait :mike do
      name { "Mike BAR" }
      nation { "CAN" }
    end
  end
end
