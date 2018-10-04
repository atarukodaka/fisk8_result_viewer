
FactoryBot.define do
  factory :deviation do
    trait :first do
      tes_deviation { 13.0 }
      pcs_deviation { 8.0 }
      tes_deviation_ratio { 1.30 }
      pcs_deviation_ratio { 1.20 }
    end

    trait :second do
      tes_deviation { 3.0 }
      pcs_deviation { 2.0 }
      tes_deviation_ratio { 0.70 }
      pcs_deviation_ratio { 0.60 }
    end
  end
end
