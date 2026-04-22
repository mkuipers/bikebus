class RoutesController < ApplicationController
  def index
    routes = Route.active.includes(:stops, :schedules)

    if params[:school].present?
      routes = routes.where("school_name ILIKE ?", "%#{params[:school]}%")
    end

    if params[:near].present?
      lat, lng = params[:near].split(",").map(&:to_f)
      radius = (params[:radius] || 10_000).to_i
      routes = routes.joins(:stops).where(
        "ST_DWithin(ST_MakePoint(stops.lng::float, stops.lat::float)::geography, ST_MakePoint(?, ?)::geography, ?)",
        lng, lat, radius
      ).distinct
    else
      routes = routes.publicly_visible
    end

    render json: routes.as_json(include: { stops: {}, schedules: {} })
  end

  def show
    render json: find_route.as_json(include: { stops: {}, schedules: {} })
  end

  def create
    route = current_user.routes.create!(route_params)
    render json: route, status: :created
  end

  def update
    route = find_owned_route
    route.update!(route_params)
    render json: route
  end

  def destroy
    find_owned_route.destroy!
    head :no_content
  end

  private

  def find_route
    Route.find(params[:id])
  end

  def find_owned_route
    current_user.routes.find(params[:id])
  end

  def route_params
    params.require(:route).permit(:name, :description, :school_name, :visibility, :active, :path_geojson)
  end
end
