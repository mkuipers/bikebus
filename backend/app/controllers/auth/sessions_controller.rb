class Auth::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: { user: user_json(resource) }, status: :ok
  end

  def respond_to_on_destroy
    render json: { message: "Signed out" }, status: :ok
  end

  # Devise 4.9+ passes resource to this hook
  alias_method :respond_to_on_destroy_with_resource, :respond_to_on_destroy
  def respond_to_on_destroy(*) = respond_to_on_destroy_with_resource

  def user_json(user)
    { id: user.id, email: user.email, display_name: user.display_name }
  end
end
