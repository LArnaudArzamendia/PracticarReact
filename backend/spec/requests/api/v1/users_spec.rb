# spec/requests/users_auth_spec.rb
require "rails_helper"

RSpec.describe "User Authentication", type: :request do
  let!(:country) { create(:country) }
  let(:password) { "password123" }
  let(:user) { create(:user, country: country, password: password) }

  describe "POST /users (sign up)" do
    let(:valid_params) do
      {
        user: {
          email: "newuser@example.com",
          password: "securePass1!",
          password_confirmation: "securePass1!",
          country_id: country.id
        }
      }
    end

    it "creates a new user" do
      expect {
        post "/users", params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:ok).or have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["email"]).to eq("newuser@example.com")
    end

    it "returns errors for invalid params" do
      post "/users", params: { user: { email: "bad", password: "short" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /users/sign_in (sign in)" do
    it "authenticates the user and returns JWT" do
      post "/users/sign_in", params: { user: { email: user.email, password: password } }
      expect(response).to have_http_status(:ok)
      expect(response.cookies).to be_present.or expect(response.headers["Authorization"]).to match(/^Bearer /)
    end

    it "rejects invalid credentials" do
      post "/users/sign_in", params: { user: { email: user.email, password: "wrongpass" } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /users/sign_out (sign out)" do
    it "logs out the user" do
      # Primero iniciar sesión
      post "/users/sign_in", params: { user: { email: user.email, password: password } }
      token = response.headers["Authorization"]&.split&.last

      delete "/users/sign_out", headers: { "Authorization" => "Bearer #{token}" }
      expect(response).to have_http_status(:ok).or have_http_status(:no_content)
    end
  end

  describe "DELETE /users (destroy account)" do
    it "deletes the user account" do
      post "/users/sign_in", params: { user: { email: user.email, password: password } }
      token = response.headers["Authorization"]&.split&.last

      expect {
        delete "/users", headers: { "Authorization" => "Bearer #{token}" }
      }.to change(User, :count).by(-1)
    end
  end
end
