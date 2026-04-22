require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:display_name) }
  it { should validate_presence_of(:email) }
  it { should have_many(:device_tokens).dependent(:destroy) }
  it { should have_many(:routes).dependent(:destroy) }
  it { should have_many(:subscriptions).dependent(:destroy) }
  it { should have_many(:leader_claims).dependent(:destroy) }

  it "is valid with valid attributes" do
    expect(build(:user)).to be_valid
  end

  it "is invalid without a display_name" do
    expect(build(:user, display_name: "")).not_to be_valid
  end
end
