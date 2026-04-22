class SchedulesController < ApplicationController
  def create
    route = current_user.routes.find(params[:route_id])
    schedule = route.schedules.create!(schedule_params)
    render json: schedule, status: :created
  end

  private

  def schedule_params
    params.require(:schedule).permit(:start_time, :timezone, :active, days_of_week: [])
  end
end
