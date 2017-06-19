FactoryGirl.define do
  factory :skater do
    name "Skater NAME"
    nation "JPN"
    isu_number 1
    category "MEN"

    trait :ladies do
      name "Foo BAR"
      nation "USA"
      isu_number 2
      category "LADIES"
    end
  end
end

FactoryGirl.define do
  factory :competition do
    name "World FS 2017"
    short_name "WORLD2017"
    competition_type "world"
    isu_championships "true"
    city "Tokyo"
    country "JPN"
    site_url "http://world2017.isu.org/results/"
    season "2016-17"
    start_date "2016-7-1"
    end_date "2016-7-3"

    trait :finlandia do
      short_name "FIN2015"
      name "Finlandia 2015"
      season "2015-16"
      competition_type "challenger"
      city "Finland"
      country "FIN"
      site_url "http://finlandia-2015/"
      isu_championships false
    end
  end
end

FactoryGirl.define do
  factory :score do
    name "WORLD2017-M-S-1"
    category "MEN"
    ranking 1
    tss 100
  end
end


FactoryGirl.define do
  factory :category_result do
    category "MEN"
    ranking 1
    points 300
    short_ranking 1
    free_ranking 1
  end
end
