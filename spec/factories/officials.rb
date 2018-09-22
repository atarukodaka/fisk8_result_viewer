FactoryBot.define do
  factory :official do
    number { 1 }
    panel { create(:panel) }
  end

  factory :panel do
    name { "John Mac" }
    nation { "USA" }
  end
end
