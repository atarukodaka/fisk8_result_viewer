# elements
FactoryBot.define do
  factory :element do
    trait :solo_jump do
      name { '4T' }
      element_type { 'jump' }
      element_subtype { 'solo' }
      value { 10 }
      goe { 2 }
      base_value { 8 }
      judges { '2 2 2' }
      info { '<' }
      credit { '+' }
      number { 1 }

      after(:create) do |element|
        #official = element.score.performed_segment.officials.find_by(number: 1)
        score = element.score
        official = score.competition.performed_segments.where(category: score.category, segment: score.segment).first.officials.find_by(number: 1)

        create(:element_judge_detail, element: element, official: official)
      end
    end
    trait :combination_jump do
      name { '3Lz+3T' }
      element_type { 'jump' }
      element_subtype { 'combination' }
      value { 15 }
      goe { 3 }
      base_value { 12 }
      judges { '3 3 3' }
      number { 2 }
    end

    trait :layback_spin do
      name { 'LSp4' }
      element_type { 'spin' }
      element_subtype { 'layback' }
      value { 2 }
      goe { -1 }
      base_value { 3 }
      judges { '-1 -1 -1' }
      info { '' }
      credit { '' }
      number { 3 }
    end
  end
end
