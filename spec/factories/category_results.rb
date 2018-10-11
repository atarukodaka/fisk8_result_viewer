# category results
FactoryBot.define do
  factory :category_result do
    trait :world do
      category { Category.find_by(name: 'MEN') }

      ranking { 1 }
      points { 300 }
      short_ranking { 1 }
      free_ranking { 1 }
    end

    trait :finlandia do
      category { Category.find_by(name: 'LADIES') }
      ranking { 2 }
      points { 240 }
      free_ranking { 2 }
    end
  end
end
