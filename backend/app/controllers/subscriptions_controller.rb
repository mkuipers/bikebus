class SubscriptionsController < ApplicationController
  def index
    render json: current_user.subscriptions.includes(:route, :pickup_stop)
      .as_json(include: { route: {}, pickup_stop: {} })
  end

  def create
    sub = current_user.subscriptions.create!(subscription_params)
    render json: sub, status: :created
  end

  def destroy
    current_user.subscriptions.find(params[:id]).destroy!
    head :no_content
  end

  private

  def subscription_params
    params.require(:subscription).permit(
      :route_id, :pickup_stop_id,
      :notify_schedule, :notify_depart, :notify_approach
    )
  end
end
