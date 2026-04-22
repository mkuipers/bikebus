require 'rails_helper'

RSpec.describe StaleLeaderCheckJob, type: :job do
  let(:ride) { create(:ride) }
  let(:user) { create(:user) }

  describe "#perform" do
    it "releases claims stale by ping time" do
      claim = LeaderClaim.create!(ride: ride, user: user, claimed_at: 10.minutes.ago, last_ping_at: 4.minutes.ago)
      described_class.new.perform
      expect(claim.reload.released_at).to be_present
    end

    it "releases claims with no ping that are old enough" do
      claim = LeaderClaim.create!(ride: ride, user: user, claimed_at: 4.minutes.ago, last_ping_at: nil)
      described_class.new.perform
      expect(claim.reload.released_at).to be_present
    end

    it "leaves fresh claims alone" do
      claim = LeaderClaim.create!(ride: ride, user: user, claimed_at: Time.current, last_ping_at: 30.seconds.ago)
      described_class.new.perform
      expect(claim.reload.released_at).to be_nil
    end

    it "leaves already-released claims alone" do
      claim = LeaderClaim.create!(ride: ride, user: user, claimed_at: 10.minutes.ago,
                                  last_ping_at: 5.minutes.ago, released_at: 1.minute.ago)
      original_released_at = claim.released_at
      described_class.new.perform
      expect(claim.reload.released_at).to be_within(1.second).of(original_released_at)
    end
  end
end
