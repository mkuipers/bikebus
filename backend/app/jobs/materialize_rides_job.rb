class MaterializeRidesJob < ApplicationJob
  queue_as :default

  # Creates Ride records for each active schedule for the next `days_ahead` days.
  # Safe to run multiple times — skips dates that already have a ride.
  def perform(days_ahead: 7)
    Schedule.includes(:route).where(active: true).find_each do |schedule|
      next unless schedule.route.active?

      days_ahead.times do |offset|
        date = Date.current + offset
        next unless schedule.days_of_week.include?(date.wday)

        scheduled_start_at = TZInfo::Timezone.get(schedule.timezone)
          .local_datetime(date.year, date.month, date.day,
                         schedule.start_time.hour, schedule.start_time.min, 0)
          .to_time.utc

        Ride.find_or_create_by!(
          route: schedule.route,
          schedule: schedule,
          scheduled_start_at: scheduled_start_at
        )
      end
    end
  end
end
