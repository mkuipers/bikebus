require 'rails_helper'

RSpec.describe Route, type: :model do
  it { should belong_to(:creator).class_name("User") }
  it { should have_many(:stops).dependent(:destroy) }
  it { should have_many(:schedules).dependent(:destroy) }
  it { should have_many(:rides).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:school_name) }
  it { should validate_inclusion_of(:visibility).in_array(%w[public private invite_only]) }

  it "is valid with valid attributes" do
    expect(build(:route)).to be_valid
  end
end
