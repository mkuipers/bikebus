Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = ENV.fetch("DEVISE_JWT_SECRET_KEY", Rails.application.credentials.secret_key_base)
    jwt.dispatch_requests = [
      ["POST", %r{^/auth/sign_in$}]
    ]
    jwt.revocation_requests = [
      ["DELETE", %r{^/auth/sign_out$}]
    ]
    jwt.expiration_time = 7.days.to_i
  end
end
