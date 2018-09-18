__END__
# categories
FactoryBot.define do
  factory :category do
    name { "MEN" }
    abbr { "SM" }
    seniority { "SENIOR" }
    category_type { "MEN" } 
    team { false } 

    trait :ladies do
      name { "LADIES" }
      abbr { "SL" }
      category_type { "LADIES" }
      seniority { "JUNIOR" }
      team { true }
    end
  end
end

# segments
FactoryBot.define do
  factory :segment do
    name { "SHORT PROGRAM" }
    abbr { "SP" }
    segment_type { "short" }

    trait :free do
      name { "FREE SKATING" }
      abbr { "FS" }
      segment_type { "free" }
    end
  end
end


