# category results
FactoryBot.define do
  factory :category_result do
    #association :skater, factory: [:skater, :men]
    #association :competition, factory: :competition
    #association :short, factory: :score
    #association :free, factory: :score

    category  { Category.find_by(name: "MEN") }
    
    ranking { 1 }
    points { 300 }
    short_ranking { 1 }
    free_ranking { 1 }

    trait :finlandia do
      #association :skater, factory: [:skater, :ladies]
      #association :competition, factory: [:competition, :finlandia]
      #association :short, factory: [:score, :finlandia]
      #association :free, factory: [:score, :finlandia]
      category { Category.find_by(name: "LADIES") }
      ranking { 2 }
      points { 240 }
      free_ranking { 2 }
    end
  end
end

################
# performed segments
FactoryBot.define do
  factory :performed_segment do
    #association :competition, factory: :competition
    #association :segment, factory: :segment
    category { Category.find_by(name: "MEN") }
    segment { Segment.find_by(name: "SHORT PROGRAM") }

    starting_time { Time.new(2017, 2, 1, 15, 0, 0) }
  
    trait :finlandia do
      #association :competition, factory: [:competition, :finlandia]
      #association :category, factory: [:category, :ladies]
      category { Category.find_by(name: "LADIES") }
      segment { Segment.find_by(name: "FREE SKATING") }
      #association :segment, factory: [:segment, :free ]
      #category { "LADIES" }
      #segment { "FREE" }
      starting_time { Time.new(2015, 9, 2, 17, 0, 0) }
    end
  end
end

