using StringToModel

# category results
FactoryBot.define do
  factory :category_result do
    trait :world do
      category { 'MEN'.to_category }

      ranking { 1 }
      points { 300 }
      short_ranking { 1 }
      free_ranking { 1 }
    end

    trait :finlandia do
      category { 'LADIES'.to_category }
      ranking { 2 }
      points { 240 }
      free_ranking { 2 }
    end
  end
end
