FactoryBot.define do
  factory :route do
    association :creator, factory: :user
    sequence(:name) { |n| "Route #{n}" }
    school_name { "Greenwood Elementary" }
    visibility { "public" }
    active { true }
  end
end
