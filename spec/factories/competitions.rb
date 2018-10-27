# competitions
FactoryBot.define do
  factory :competition do
    trait :world do
      name { 'World FS 2015' }
      short_name { 'WORLD2015' }
      competition_type { 'world' }
      competition_class { 'isu' }
      city { 'Tokyo' }
      country { 'JPN' }
      site_url { 'http://world2015.isu.org/results/' }
      season { '2014-15' }
      start_date { Date.new(2015, 2, 1) }
      end_date { Date.new(2015, 2, 3) }
      timezone { 'Asia/Tokyo' }

      after(:build) do |competition|
        skater = create(:skater, :men)
        create(:performed_segment, :world, competition: competition)
        create(:category_result, :world, competition: competition, skater: skater)
        create(:score, :world, competition: competition, skater: skater)
      end
    end

    trait :finlandia do
      short_name { 'FIN2017' }
      name { 'Finlandia 2017' }
      season { '2017-18' }
      competition_type { 'finlandia' }
      competition_class { 'challenger' }
      city { 'Finland' }
      country { 'FIN' }
      site_url { 'http://finlandia-2017/' }
      start_date { Date.new(2017, 9, 1) }
      end_date { Date.new(2017, 9, 3) }
      timezone { 'UTC' }
      after(:build) do |competition|
        skater = create(:skater, :ladies)
        create(:performed_segment, :finlandia, competition: competition)
        create(:category_result, :finlandia, competition: competition, skater: skater)
        create(:score, :finlandia, competition: competition, skater: skater)
      end
    end
  end
end
