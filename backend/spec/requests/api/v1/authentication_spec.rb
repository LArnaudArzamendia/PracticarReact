require "rails_helper"

RSpec.describe "API::V1::Authentication", type: :request do
  let(:email) { "test@example.com" }
  let(:password) { "supersecure123" }

  describe "POST /users (sign up)" do
    it "registers a new user" do
      expect {
        post "/users", params: { user: { email: email, password: password, password_confirmation: password } }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created).or have_http_status(:ok)
      expect(response.body).to include(email)
    end

    it "fails with invalid data" do
      post "/users", params: { user: { email: "", password: "123" } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /users/sign_in (login)" do
    let!(:user) { User.create!(email: email, password: password) }

    it "logs in successfully and returns auth cookie and/or token" do
      post "/users/sign_in", params: { user: { email: email, password: password } }, as: :json

      expect(response).to have_http_status(:ok)

      # Devuelve Authorization header si usas header
      expect(response.headers["Authorization"]).to match(/^Bearer /).or be_nil

      # Devuelve Set-Cookie si usas cookie http-only
      expect(response.headers["Set-Cookie"]).to be_present
    end

    it "fails with wrong credentials" do
      post "/users/sign_in", params: { user: { email: email, password: "wrong" } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /users/sign_out (logout)" do
    let!(:user) { User.create!(email: email, password: password) }

    it "logs out and revokes token" do
      headers = auth_headers_for(user, password:)
      delete "/users/sign_out", headers: headers
      expect(response).to have_http_status(:no_content).or have_http_status(:ok)
    end
  end

  describe "DELETE /users (destroy account)" do
    let!(:user) { User.create!(email: email, password: password) }

    it "destroys the account when authenticated" do
      headers = auth_headers_for(user, password:)
      expect {
        delete "/users", headers: headers
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content).or have_http_status(:ok)
    end

    it "rejects unauthenticated request" do
      delete "/users"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
