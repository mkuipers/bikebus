require 'rails_helper'

RSpec.describe Schedule, type: :model do
  it { should belong_to(:route) }
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:timezone) }
  it { should validate_presence_of(:days_of_week) }

  it "is valid with valid attributes" do
    route = create(:route)
    schedule = Schedule.new(route: route, start_time: "08:00", timezone: "America/Los_Angeles", days_of_week: [1, 3, 5])
    expect(schedule).to be_valid
  end
end
