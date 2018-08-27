# skaters
FactoryBot.define do
  factory :skater do
    name { "Taro YAMADA" }
    nation { "JPN" }
    isu_number { 1 }
    category { "MEN" }
    birthday { "1.1.1980" } 
    coach { "Jiro YAMADA" }
    hometown { "TOKYO" }
    club { "Jingu" } 

    trait :ladies do
      name { "Leia ORGANA" }
      nation { "USA" }
      isu_number { 2 }
      category { "LADIES" }
      birthday { "1.1.1990" }
      coach { "Rola ORGANA" }
      hometown { "L.A." }
      club { "Cri" } 
    end
  end
end

# competitions
FactoryBot.define do
  factory :competition do
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

    end
  end
end

# category results
FactoryBot.define do
  factory :category_result do
    association :skater, factory: :skater
    association :competition, factory: :competition
    category { "MEN" }
    ranking { 1 }
    points { 300 }
    short_ranking { 1 }
    free_ranking { 1 }

    trait :finlandia do
      association :skater, factory: [:skater, :ladies]
      association :competition, factory: [:competition, :finlandia]
      category { "LADIES" }
      ranking { 2 }
      points { 240 }
      free_ranking { 2 }
    end
  end
end

# scores
FactoryBot.define do
  factory :score do
    association :skater, factory: :skater
    association :competition, factory: :competition
    name { "WORLD2017-M-S-1" }
    category { "MEN" }
    segment { "SHORT" }
    ranking { 1 }
    tss { 100 }
    tes { 50 }
    pcs { 50 }
    base_value { 25 }
    deductions { 0 }
    segment_starting_time { '2017-2-1 00:00:00'.in_time_zone('UTC') }
    result_pdf { 'http://world2017.isu.org/results/men/short.pdf' }

    trait :world_free do
      segment { "FREE" }
    end

    trait :finlandia do
      association :skater, factory: [:skater, :ladies]
      association :competition, factory: [:competition, :finlandia]
      name { 'FIN2015-L-F-2' }
      category { 'LADIES' }
      segment { 'FREE' }
      ranking { 2 }
      tss { 160 }
      tes { 80 }
      pcs { 80 }
      base_value { 40 }
      deductions { -1 }
      segment_starting_time { '2015-7-1 00:00:00'.in_time_zone('UTC')}
      result_pdf { "http://finlandia-2015/ladies/free.pdf" }
    end

    trait :finlandia_short do
      segment { 'SHORT' }
    end
  end
end

# elements
FactoryBot.define do
  factory :element do
    association :score, factory: :score
    name { "4T" }
    element_type { "jump" }
    value { 10 }
    goe { 2 }
    base_value { 8 }
    judges { "2 2 2" }
    info { "<" }
    credit { "+" }
    number { 1 }
    
    trait :combination do
      name { "4T3T" }
      value { 15 }
      goe { 3 }
      base_value { 12 }
      judges { "3 3 3" }
      number { 2 }
    end

    trait :spin do
      association :score, factory: [:score, :finlandia]
      name { "LSp4" }
      value { 2 }
      goe { -1 }
      base_value { 3 }
      judges { "-1 -1 -1" }
      info { "" }
      credit { "" }
      number { 3 }
    end
  end
end

    
