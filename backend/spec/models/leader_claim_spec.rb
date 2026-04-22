require 'rails_helper'

RSpec.describe LeaderClaim, type: :model do
  it { should belong_to(:ride) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:claimed_at) }

  describe "#stale?" do
    let(:claim) { LeaderClaim.new(claimed_at: Time.current) }

    it "returns false when last_ping_at is recent" do
      claim.last_ping_at = 1.minute.ago
      expect(claim.stale?).to be false
    end

    it "returns true when no ping for over 3 minutes" do
      claim.last_ping_at = 4.minutes.ago
      expect(claim.stale?).to be true
    end

    it "returns false when last_ping_at is nil" do
      claim.last_ping_at = nil
      expect(claim.stale?).to be false
    end
  end
end
