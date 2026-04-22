FactoryBot.define do
  factory :stop do
    association :route
    sequence(:position) { |n| n }
    sequence(:name) { |n| "Stop #{n}" }
    lat { 47.6062 }
    lng { -122.3321 }
    scheduled_offset_minutes { 0 }
  end
end
