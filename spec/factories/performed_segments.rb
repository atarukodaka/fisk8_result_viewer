################
# performed segments
FactoryBot.define do
  factory :performed_segment do
    after(:build) do |ps|
      create(:official, :first, performed_segment: ps)
      create(:official, :second, performed_segment: ps)
    end

    trait :world do
      category { Category.find_by(name: 'TEAM MEN') }
      segment { Segment.find_by(name: 'SHORT PROGRAM') }
      # starting_time { Time.new(2017, 2, 1, 15, 0, 0) }
      starting_time { '2015-2-1 15:00:00' }
    end

    trait :finlandia do
      category { Category.find_by(name: 'JUNIOR LADIES') }
      segment { Segment.find_by(name: 'FREE SKATING') }
      # starting_time { Time.new(2015, 9, 2, 17, 0, 0) }
      starting_time { '2017-9-1 15:00:00' }
    end

    trait :ice_dance do
      category { Category.find_by(name: 'ICE DANCE') }
      segment { Segment.find_by(name: 'RYTHM DANCE') }
      starting_time { '2015-2-2 15:00:00' }
    end
  end
end
