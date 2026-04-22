module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      reject_unauthorized_connection if token.blank?

      payload, = JWT.decode(
        token,
        Rails.application.credentials.secret_key_base,
        true,
        algorithms: ["HS256"]
      )

      user = User.find(payload["sub"])
      reject_unauthorized_connection unless user.jti == payload["jti"]
      user
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      reject_unauthorized_connection
    end
  end
end
