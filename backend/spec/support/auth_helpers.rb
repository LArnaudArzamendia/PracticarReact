# spec/support/auth_helpers.rb
module AuthHelpers
  def auth_headers_for(user, password: "password")
    post "/users/sign_in",
         params: { user: { email: user.email, password: password } },
         as: :json

    headers = {}

    # Header Authorization
    if (auth = response.headers["Authorization"])
      token = auth.split.last
      headers["Authorization"] = "Bearer #{token}" if token
    end

    # Set-Cookie puede venir como String o Array
    set_cookie = response.headers["Set-Cookie"]

    raw_cookie =
      case set_cookie
      when String
        extract_cookie_string(set_cookie)
      when Array
        set_cookie.map { |c| extract_cookie_string(c) }.join("; ")
      end

    headers["Cookie"] = raw_cookie if raw_cookie.present?

    headers
  end

  private

  # Extrae solo la parte clave=valor del Set-Cookie
  def extract_cookie_string(set_cookie)
    set_cookie.split(";").first
  end
end
