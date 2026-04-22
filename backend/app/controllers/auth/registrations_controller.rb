class Auth::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :display_name, :phone)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { user: user_json(resource) }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def user_json(user)
    { id: user.id, email: user.email, display_name: user.display_name }
  end
end
