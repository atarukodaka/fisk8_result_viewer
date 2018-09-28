# scores
FactoryBot.define do
  factory :score do
    trait :world do
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
        segment { Segment.find_by(name: "FREE SKATING") }
      end
    end

    trait :finlandia do
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
      segment { Segment.find_by(name: "SHORT PROGRAM") }
    end
  end
end

    
