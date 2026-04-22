FactoryBot.define do
  factory :ride do
    association :route
    scheduled_start_at { 1.hour.from_now }
    status { "scheduled" }
  end
end
