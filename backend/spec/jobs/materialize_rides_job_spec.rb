require 'rails_helper'

RSpec.describe MaterializeRidesJob, type: :job do
  let(:route) { create(:route, active: true) }

  def make_schedule(days:, time: "08:00", tz: "UTC")
    Schedule.create!(
      route: route,
      days_of_week: days,
      start_time: time,
      timezone: tz,
      active: true
    )
  end

  describe "#perform" do
    it "creates rides for matching days in the next 7 days" do
      all_days = [0, 1, 2, 3, 4, 5, 6]
      make_schedule(days: all_days)

      expect { described_class.new.perform }.to change(Ride, :count).by(7)
    end

    it "skips days that don't match the schedule" do
      # Only Monday (wday=1)
      make_schedule(days: [1])
      expect { described_class.new.perform }.to change(Ride, :count).by(
        (0..6).count { |i| (Date.current + i).wday == 1 }
      )
    end

    it "is idempotent — does not create duplicate rides" do
      make_schedule(days: [0, 1, 2, 3, 4, 5, 6])
      described_class.new.perform
      expect { described_class.new.perform }.not_to change(Ride, :count)
    end

    it "skips inactive schedules" do
      Schedule.create!(route: route, days_of_week: [0, 1, 2, 3, 4, 5, 6],
                       start_time: "08:00", timezone: "UTC", active: false)
      expect { described_class.new.perform }.not_to change(Ride, :count)
    end

    it "skips inactive routes" do
      route.update!(active: false)
      make_schedule(days: [0, 1, 2, 3, 4, 5, 6])
      expect { described_class.new.perform }.not_to change(Ride, :count)
    end

    it "sets scheduled_start_at correctly in the schedule's timezone" do
      # Use a timezone that's clearly offset — Pacific is UTC-7 or UTC-8
      make_schedule(days: [0, 1, 2, 3, 4, 5, 6], time: "08:00", tz: "America/Los_Angeles")
      described_class.new.perform
      ride = Ride.first
      # 08:00 LA time should be 15:00 or 16:00 UTC (depending on DST)
      expect(ride.scheduled_start_at.hour).to be_between(14, 16)
    end
  end
end
