require 'rails_helper'

RSpec.describe Stop, type: :model do
  it { should belong_to(:route) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lat) }
  it { should validate_presence_of(:lng) }
  it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }

  it "is valid with valid attributes" do
    expect(build(:stop)).to be_valid
  end
end
