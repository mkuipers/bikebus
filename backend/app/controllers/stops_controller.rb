class StopsController < ApplicationController
  def create
    route = current_user.routes.find(params[:route_id])
    stop = route.stops.create!(stop_params)
    render json: stop, status: :created
  end

  private

  def stop_params
    params.require(:stop).permit(:name, :lat, :lng, :position, :scheduled_offset_minutes)
  end
end
