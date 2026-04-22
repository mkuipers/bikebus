require 'rails_helper'

RSpec.describe DeviceToken, type: :model do
  subject { build(:device_token, user: create(:user), fcm_token: "tok_unique") }

  it { should belong_to(:user) }
  it { should validate_presence_of(:fcm_token) }
  it { should validate_uniqueness_of(:fcm_token) }
  it { should validate_inclusion_of(:platform).in_array(%w[ios android]) }
end
