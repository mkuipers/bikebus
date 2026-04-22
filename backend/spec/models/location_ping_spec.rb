require 'rails_helper'

RSpec.describe LocationPing, type: :model do
  it { should belong_to(:ride) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:lat) }
  it { should validate_presence_of(:lng) }
  it { should validate_presence_of(:recorded_at) }

  describe ".distance_metres" do
    it "returns ~0 for identical coordinates" do
      d = LocationPing.distance_metres(47.6062, -122.3321, 47.6062, -122.3321)
      expect(d).to be_within(0.01).of(0)
    end

    it "returns roughly correct distance between two points" do
      # Space Needle to Pike Place Market ~1.4km
      d = LocationPing.distance_metres(47.6205, -122.3493, 47.6095, -122.3421)
      expect(d).to be_within(200).of(1400)
    end
  end
end
