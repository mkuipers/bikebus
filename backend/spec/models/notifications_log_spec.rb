require 'rails_helper'

RSpec.describe NotificationsLog, type: :model do
  it { should belong_to(:ride) }
  it { should belong_to(:subscription) }
  it { should validate_inclusion_of(:kind).in_array(%w[reminder depart approach]) }

  it "prevents duplicate (ride, subscription, kind) entries" do
    ride = create(:ride)
    sub = create(:subscription)
    NotificationsLog.create!(ride: ride, subscription: sub, kind: "depart")
    dup = NotificationsLog.new(ride: ride, subscription: sub, kind: "depart")
    expect(dup).not_to be_valid
  end

  it "allows different kinds for same ride+subscription" do
    ride = create(:ride)
    sub = create(:subscription)
    NotificationsLog.create!(ride: ride, subscription: sub, kind: "depart")
    log = NotificationsLog.new(ride: ride, subscription: sub, kind: "approach")
    expect(log).to be_valid
  end
end
