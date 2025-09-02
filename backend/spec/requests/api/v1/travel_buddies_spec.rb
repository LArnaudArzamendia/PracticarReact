# spec/requests/api/v1/travel_buddies_spec.rb
require "rails_helper"

RSpec.describe "API::V1::TravelBuddies", type: :request do
  # Helper local: obtiene "Cookie" => "app_jwt=<token>"
  def auth_cookie_for(user, password: "password123")
    post "/users/sign_in", params: { user: { email: user.email, password: password } }
    cookies = Array(response.get_header("Set-Cookie"))
    raw = cookies.find { |c| c.start_with?("app_jwt=") }
    raise "JWT cookie not found in Set-Cookie=#{cookies.inspect}" unless raw
    token = raw.match(/app_jwt=([^;]+)/)[1]
    "app_jwt=#{token}"
  end

  let(:owner) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:trip)  { create(:trip, user: owner) }
  let(:cookie) { auth_cookie_for(owner) }

  describe "GET /api/v1/trips/:trip_id/travel_buddies" do
    it "lista los buddies del trip, incluyendo user y met_location" do
      tb = create(:travel_buddy, trip: trip, user: create(:user))
      get "/api/v1/trips/#{trip.id}/travel_buddies", headers: { "Cookie" => cookie }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["id"]).to eq(tb.id)
      expect(json.first["user_id"]).to eq(tb.user_id)
    end

    it "filtra por can_post cuando se pasa el parámetro" do
      create(:travel_buddy, trip: trip, user: create(:user), can_post: true)
      create(:travel_buddy, trip: trip, user: create(:user), can_post: false)

      get "/api/v1/trips/#{trip.id}/travel_buddies",
          params: { can_post: true },
          headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.all? { |h| h["can_post"] == true }).to be true
    end
  end

  describe "POST /api/v1/trips/:trip_id/travel_buddies" do
    it "agrega un buddy por user_id" do
      buddy = create(:user)
      expect {
        post "/api/v1/trips/#{trip.id}/travel_buddies",
             params: { user_id: buddy.id, can_post: true, met_on: Date.today.to_s },
             headers: { "Cookie" => cookie }
      }.to change(TravelBuddy, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["user_id"]).to eq(buddy.id)
      expect(body["can_post"]).to eq(true)
    end

    it "agrega un buddy por handle y crea met_location en línea si no existe" do
      buddy   = create(:user, handle: "@buddy")
      country = create(:country) # asegúrate que tu factory usa sequences para campos únicos

      expect {
        post "/api/v1/trips/#{trip.id}/travel_buddies",
             params: {
               user_handle: buddy.handle,
               met_on: Date.today.to_s,
               met_location: { name: "Las Condes", country_id: country.id }
             },
             headers: { "Cookie" => cookie }
      }.to change(TravelBuddy, :count).by(1)

      expect(response).to have_http_status(:created)
      tb = TravelBuddy.last
      expect(tb.user_id).to eq(buddy.id)
      expect(tb.met_location).to be_present
      expect(tb.met_location.name.downcase).to include("condes")
    end

    it "es idempotente: si ya existe el buddy en el trip, retorna 200 y no duplica" do
      buddy = create(:user)
      create(:travel_buddy, trip: trip, user: buddy)

      expect {
        post "/api/v1/trips/#{trip.id}/travel_buddies",
             params: { user_id: buddy.id, can_post: false },
             headers: { "Cookie" => cookie }
      }.not_to change(TravelBuddy, :count)

      expect(response).to have_http_status(:ok)
    end

    it "rechaza agregarse a sí mismo" do
      post "/api/v1/trips/#{trip.id}/travel_buddies",
           params: { user_id: owner.id },
           headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to be_present
    end

    it "retorna 404 si user_handle no existe" do
      post "/api/v1/trips/#{trip.id}/travel_buddies",
           params: { user_handle: "@no-existe" },
           headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /api/v1/trips/:trip_id/travel_buddies/:id" do
    it "actualiza can_post y met_on" do
      tb = create(:travel_buddy, trip: trip, user: create(:user), can_post: false)
      put "/api/v1/trips/#{trip.id}/travel_buddies/#{tb.id}",
          params: { travel_buddy: { can_post: true, met_on: Date.yesterday.to_s } },
          headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:ok)
      expect(tb.reload.can_post).to be true
      expect(tb.met_on).to eq(Date.yesterday)
    end

    it "puede cambiar met_location por id" do
      tb = create(:travel_buddy, trip: trip, user: create(:user))
      new_loc = create(:location)
      put "/api/v1/trips/#{trip.id}/travel_buddies/#{tb.id}",
          params: { met_location_id: new_loc.id, travel_buddy: { can_post: tb.can_post } },
          headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:ok)
      expect(tb.reload.met_location_id).to eq(new_loc.id)
    end
  end

  describe "DELETE /api/v1/trips/:trip_id/travel_buddies/:id" do
    it "elimina el buddy del trip" do
      tb = create(:travel_buddy, trip: trip, user: create(:user))
      expect {
        delete "/api/v1/trips/#{trip.id}/travel_buddies/#{tb.id}",
               headers: { "Cookie" => cookie }
      }.to change(TravelBuddy, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "autorización" do
    it "forbids a un usuario que no es dueño del trip" do
      stranger = create(:user, password: "password123", password_confirmation: "password123")
      stranger_cookie = auth_cookie_for(stranger)

      buddy = create(:user)
      post "/api/v1/trips/#{trip.id}/travel_buddies",
           params: { user_id: buddy.id },
           headers: { "Cookie" => stranger_cookie }

      expect(response).to have_http_status(:forbidden)
    end

    it "retorna 404 si el trip no existe" do
      post "/api/v1/trips/999999/travel_buddies",
           params: { user_id: create(:user).id },
           headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:not_found)
    end

    it "retorna 404 al actualizar/eliminar un buddy inexistente" do
      put "/api/v1/trips/#{trip.id}/travel_buddies/999999",
          params: { travel_buddy: { can_post: true } },
          headers: { "Cookie" => cookie }
      expect(response).to have_http_status(:not_found)

      delete "/api/v1/trips/#{trip.id}/travel_buddies/999999",
             headers: { "Cookie" => cookie }
      expect(response).to have_http_status(:not_found)
    end
  end
end
