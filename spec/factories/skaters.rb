# skaters
FactoryBot.define do
  factory :skater do
    association :category, factory: :category
    
    name { "Taro YAMADA" }
      nation { "JPN" }
      isu_number { 1 }
      
      birthday { "1.1.1980" } 
      coach { "Jiro YAMADA" }
      hometown { "TOKYO" }
      club { "Jingu" } 
    
    trait :ladies do
      association :category, factory: [:category, :ladies]
      name { "Leia ORGANA" }
      nation { "USA" }
      isu_number { 2 }
      birthday { "1.1.1990" }
      coach { "Rola ORGANA" }
      hometown { "L.A." }
      club { "Cri" } 
    end
  end
end

