FactoryGirl.define do
  factory :skater do
    name "Skater NAME"
    nation "JPN"
    isu_number 1
  end
end

FactoryGirl.define do
  factory :competition do
    cid "WORLD2017"
    country "JPN"
  end
end



