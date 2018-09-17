# competitions
FactoryBot.define do
  factory :competition do

    trait :world do 
      name { "World FS 2017" }
      short_name { "WORLD2017" }
      competition_type { "world" }
      competition_class { "isu" }
      city { "Tokyo" }
      country { "JPN" }
      site_url { "http://world2017.isu.org/results/" }
      season { "2016-17" }
      start_date { "2017-2-1" }
      end_date { "2017-2-3" }

      after (:build) do |competition|
        skater = create(:skater, :men)
        create(:performed_segment, competition: competition)
        create(:category_result, competition: competition, skater: skater)
        create(:score, competition: competition, skater: skater)
      end
    end
    
    trait :finlandia do
      short_name { "FIN2015" }
      name { "Finlandia 2015" }
      season { "2015-16" }
      competition_type { "finlandia" }
      competition_class { "challenger" }
      city { "Finland" }
      country { "FIN" }
      site_url { "http://finlandia-2015/" }
      start_date { "2015-9-1" }
      end_date { "2015-9-3" }
      
      after (:build) do |competition|
        skater = create(:skater, :ladies)
        create(:performed_segment, :finlandia, competition: competition)
        create(:category_result, :finlandia, competition: competition, skater: skater)
        create(:score, :finlandia, competition: competition, skater: skater)
      end

    end
  end
end

