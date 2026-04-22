require "net/http"
require "googleauth"

class FcmService
  FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"

  # Send the same notification to multiple FCM tokens, silently skipping blanks.
  def self.send_to_tokens(tokens, title:, body:, data: {})
    tokens.compact.reject(&:blank?).each do |token|
      send_message(token, title: title, body: body, data: data)
    end
  end

  def self.send_message(token, title:, body:, data: {})
    project_id = credentials["project_id"]
    uri = URI("https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{fresh_access_token}"
    req["Content-Type"]  = "application/json"
    req.body = {
      message: {
        token: token,
        notification: { title: title, body: body },
        data: data.transform_values(&:to_s)
      }
    }.to_json

    resp = http.request(req)
    unless resp.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("[FCM] send failed for token #{token[..10]}...: #{resp.code} #{resp.body}")
    end
    resp
  rescue => e
    Rails.logger.error("[FCM] error: #{e.message}")
    nil
  end

  def self.fresh_access_token
    creds = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(ENV.fetch("FIREBASE_CREDENTIALS_JSON")),
      scope: FCM_SCOPE
    )
    creds.fetch_access_token!["access_token"]
  end

  def self.credentials
    @credentials ||= JSON.parse(ENV.fetch("FIREBASE_CREDENTIALS_JSON"))
  end
end
