class DeviceToken < ApplicationRecord
  belongs_to :user

  validates :fcm_token, presence: true, uniqueness: true
  validates :platform, inclusion: { in: %w[ios android] }
end
