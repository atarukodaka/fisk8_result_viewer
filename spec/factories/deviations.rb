
FactoryBot.define do
  factory :deviation do
    trait :first do
      tes_deviation { 13.0 }
      pcs_deviation { 8.0 }
      tes_ratio { 1.30 }
      pcs_ratio { 1.20 }
      num_elements { 7 }
    end

    trait :second do
      tes_deviation { 3.0 }
      pcs_deviation { 2.0 }
      tes_ratio { 0.70}
      pcs_ratio { 0.60 }
      num_elements { 13 }
    end
  end
end
