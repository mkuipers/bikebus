class Auth::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: { user: user_json(resource) }, status: :ok
  end

  def respond_to_on_destroy
    render json: { message: "Signed out" }, status: :ok
  end

  def user_json(user)
    { id: user.id, email: user.email, display_name: user.display_name }
  end
end
