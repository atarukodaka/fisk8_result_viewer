using StringToModel

# skaters
FactoryBot.define do
  factory :skater do
    trait :men do
      name { 'Taro YAMADA' }
      nation { 'JPN' }
      category_type { 'MEN'.to_category_type }
      isu_number { 1 }

      birthday { '1.1.1980' }
      coach { 'Jiro YAMADA' }
      hometown { 'TOKYO' }
      club { 'Jingu' }
    end

    trait :ladies do
      name { 'Leia ORGANA' }
      nation { 'USA' }
      category_type { 'LADIES'.to_category_type }
      isu_number { 2 }
      birthday { '1.1.1990' }
      coach { 'Rola ORGANA' }
      hometown { 'L.A.' }
      club { 'Cri' }
    end

    trait :ice_dance do
      name { 'ADAM / EVE' }
      nation { 'GRC' }
      category_type { 'ICE DANCE'.to_category_type }
      isu_number { 3 }
    end

    ################
    trait :no_scores do
      name { 'No SCORES' }
      nation { 'CAN' }
      category_type { 'MEN'.to_category_type }
      isu_number { 4 }
    end
  end
end
