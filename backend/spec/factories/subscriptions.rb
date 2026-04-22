FactoryBot.define do
  factory :subscription do
    association :user
    association :route
    association :pickup_stop, factory: :stop
  end
end
