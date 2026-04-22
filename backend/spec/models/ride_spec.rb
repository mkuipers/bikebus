require 'rails_helper'

RSpec.describe Ride, type: :model do
  it { should belong_to(:route) }
  it { should belong_to(:schedule).optional }
  it { should have_one(:leader_claim) }
  it { should have_many(:location_pings).dependent(:destroy) }
  it { should validate_inclusion_of(:status).in_array(%w[scheduled in_progress completed cancelled]) }

  describe "#needs_leader?" do
    let(:ride) { create(:ride, scheduled_start_at: 1.hour.from_now) }

    it "returns true when no leader claimed" do
      expect(ride.needs_leader?).to be true
    end

    it "returns false when ride is not in the 2-hour window" do
      ride.update!(scheduled_start_at: 3.hours.from_now)
      expect(ride.needs_leader?).to be false
    end
  end
end
