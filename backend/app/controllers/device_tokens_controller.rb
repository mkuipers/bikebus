class DeviceTokensController < ApplicationController
  def create
    token = current_user.device_tokens.find_or_initialize_by(fcm_token: params[:fcm_token])
    token.assign_attributes(platform: params[:platform], last_seen_at: Time.current)
    token.save!
    render json: token, status: :created
  end
end
