using StringToModel

FactoryBot.define do
  factory :performed_segment do
    after(:build) do |ps|
      create(:official, :first, performed_segment: ps)
      create(:official, :second, performed_segment: ps)
    end

    trait :world do
      category { 'TEAM MEN'.to_category }
      segment {'SHORT PROGRAM'.to_segment }
      # starting_time { Time.new(2017, 2, 1, 15, 0, 0) }
      starting_time { '2015-2-1 15:00:00' }
    end

    trait :finlandia do
      category { 'JUNIOR LADIES'.to_category }
      segment { 'FREE SKATING'.to_segment }
      # starting_time { Time.new(2015, 9, 2, 17, 0, 0) }
      starting_time { '2017-9-1 15:00:00' }
    end

    trait :ice_dance do
      category { 'ICE DANCE'.to_category }
      segment { 'RYTHM DANCE'.to_segment }
      starting_time { '2015-2-2 15:00:00' }
    end
  end
end
