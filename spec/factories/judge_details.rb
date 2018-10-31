FactoryBot.define do
  factory :judge_detail do
    trait :element do
      number { 1 }
      value { 0.0 }
      # average { 1.0 }
      # deviation { -1.0 }
      # abs_deviation { 1.0 }
    end
  end
end
