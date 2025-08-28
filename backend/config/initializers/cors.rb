# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development? || Rails.env.test?
    allow do
      origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")
      resource "*",
               headers: :any,
               methods: %i[get post put patch delete options head],
               credentials: true
    end
  else
    allowed_origin = ENV["FRONTEND_ORIGIN"]
    if allowed_origin.present?
      allow do
        origins allowed_origin
        resource "*",
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 credentials: true
      end
    end
  end
end
