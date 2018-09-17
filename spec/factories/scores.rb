# scores
FactoryBot.define do
  factory :score do
    #association :skater, factory: [:skater, :men]
    #association :competition, factory: [:competition, :world]
    
    name { "WORLD2017-SM-SP-1" }
    category { Category.find_by(name: "TEAM MEN") }
    segment { Segment.find_by(name: "SHORT PROGRAM") }

    ranking { 1 }
    tss { 100 }
    tes { 50 }
    pcs { 50 }
    base_value { 25 }
    deductions { 0 }
    date { '2017-2-1' }
    result_pdf { 'http://world2017.isu.org/results/men/short.pdf' }

    trait :world_free do
      association :segment, factory: [:segment, :free]
    end

    trait :finlandia do
      #association :skater, factory: [:skater, :ladies]
      #association :competition, factory: [:competition, :finlandia]
      name { 'FIN2015-SL-FS-2' }
      category { Category.find_by(name: "JUNIOR LADIES") }
      segment { Segment.find_by(name: "FREE SKATING") }

      ranking { 2 }
      tss { 160 }
      tes { 80 }
      pcs { 80 }
      base_value { 40 }
      deductions { -1 }
      date { '2015-7-1' }
      result_pdf { "http://finlandia-2015/ladies/free.pdf" }
    end

    trait :finlandia_short do
      association :segment, factory: :segment
    end
  end
end

    
