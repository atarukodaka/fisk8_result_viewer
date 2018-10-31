using StringToModel

FactoryBot.define do
  factory :score do
    trait :world do
      name { 'WORLD2015-SM-SP-1' }
      category { 'TEAM MEN'.to_category }
      segment { 'SHORT PROGRAM'.to_segment }

      ranking { 1 }
      tss { 100 }
      tes { 50 }
      pcs { 50 }
      base_value { 25 }
      deductions { 0 }
      date { '2015-2-1' }
      result_pdf { 'http://world2017.isu.org/results/men/short.pdf' }

      after(:build) do |score|
        element = create(:element, :solo_jump, score: score)
        create(:element, :combination_jump, score: score)
        create(:judge_detail, :element, detailable: element, official: score.performed_segment.officials.first)
        create(:component, :ss, score: score)
      end

      trait :world_free do
        segment { 'FREE SKATING'.to_segment }
      end
    end

    trait :finlandia do
      name { 'FIN2017-JL-FS-2' }
      category { 'JUNIOR LADIES'.to_category }
      segment { 'FREE SKATING'.to_segment }

      ranking { 2 }
      tss { 160 }
      tes { 80 }
      pcs { 80 }
      base_value { 40 }
      deductions { -1 }
      date { '2017-9-1' }
      result_pdf { 'http://finlandia-2015/ladies/free.pdf' }

      after(:build) do |score|
        create(:element, :layback_spin, score: score)
        create(:component, :tr, score: score)
      end
    end

    trait :finlandia_short do
      segment { 'SHORT PROGRAM'.to_segment }
    end
  end
end
