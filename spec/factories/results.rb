# category results
FactoryBot.define do
  factory :category_result do
    association :skater, factory: :skater
    association :competition, factory: :competition
    association :short, factory: :score
    association :free, factory: :score
    association :category, factory: :category
    #category { "MEN" }
    ranking { 1 }
    points { 300 }
    short_ranking { 1 }
    free_ranking { 1 }

    trait :finlandia do
      association :skater, factory: [:skater, :ladies]
      association :competition, factory: [:competition, :finlandia]
      association :short, factory: [:score, :finlandia]
      association :free, factory: [:score, :finlandia]
      association :category, factory: [:category, :ladies]
      #category { "LADIES" }
      ranking { 2 }
      points { 240 }
      free_ranking { 2 }
    end
  end
end

# performed segments
FactoryBot.define do
  factory :performed_segment do
    association :competition, factory: :competition
    association :category, factory: :category
    association :segment, factory: :segment
    #category { "MEN" }
    #segment { "SHORT" }
    starting_time { Time.new(2017, 2, 1, 15, 0, 0) }
  
    trait :finlandia do
      association :competition, factory: [:competition, :finlandia]
      association :category, factory: [:category, :ladies]
      association :segment, factory: [:segment, :free ]
      #category { "LADIES" }
      #segment { "FREE" }
      starting_time { Time.new(2015, 9, 2, 17, 0, 0) }
    end
  end
end

