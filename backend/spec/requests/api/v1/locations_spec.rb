# spec/requests/api/v1/locations_spec.rb
require "rails_helper"

RSpec.describe API::V1::LocationsController, type: :request do
  let!(:country) { create(:country) }
  let!(:locations) { create_list(:location, 3, country: country) }
  let(:location_id) { locations.first.id }

  describe "GET /api/v1/locations" do
    it "returns all locations" do
      get "/api/v1/locations"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end
  end

  describe "GET /api/v1/locations/:id" do
    it "returns the location" do
      get "/api/v1/locations/#{location_id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(location_id)
    end

    it "returns 404 if location not found" do
      get "/api/v1/locations/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/locations" do
    let(:valid_attributes) do
      {
        location: {
          name: "Test City",
          latitude: -33.4489,
          longitude: -70.6693,
          country_id: country.id
        }
      }
    end

    context "when request is valid" do
      it "creates a location" do
        expect {
          post "/api/v1/locations", params: valid_attributes
        }.to change(Location, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when request is invalid" do
      it "returns unprocessable_content" do
        post "/api/v1/locations", params: { location: { country_id: country.id } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PUT /api/v1/locations/:id" do
    let(:new_name) { "Updated Name" }

    it "updates the location" do
      put "/api/v1/locations/#{location_id}", params: { location: { name: new_name } }
      expect(response).to have_http_status(:ok)
      expect(Location.find(location_id).name).to eq(new_name)
    end
  end

  describe "DELETE /api/v1/locations/:id" do
    it "deletes the location" do
      expect {
        delete "/api/v1/locations/#{location_id}"
      }.to change(Location, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
