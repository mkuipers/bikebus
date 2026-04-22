FactoryBot.define do
  factory :device_token do
    association :user
    sequence(:fcm_token) { |n| "fcm_token_#{n}" }
    platform { "ios" }
  end
end
