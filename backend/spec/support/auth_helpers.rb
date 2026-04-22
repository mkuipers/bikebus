module AuthHelpers
  def sign_in_as(user)
    post "/auth/sign_in",
      params: { user: { email: user.email, password: user.password || "password123" } },
      as: :json
    response.headers["Authorization"]
  end

  def auth_headers(token)
    { "Authorization" => token }
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
