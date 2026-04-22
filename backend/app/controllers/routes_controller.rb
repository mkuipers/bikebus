class RoutesController < ApplicationController
  def index
    routes = Route.active.publicly_visible
    render json: routes
  end

  def show
    render json: find_route
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
