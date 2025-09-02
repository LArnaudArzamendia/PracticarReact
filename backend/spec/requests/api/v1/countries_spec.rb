# spec/requests/api/v1/countries_spec.rb
require "rails_helper"

RSpec.describe "API::V1::Countries", type: :request do
  let!(:chile) do
    Country.create!(
      iso2: "CL", iso3: "CHL", numeric_code: "152",
      name_en: "Chile", name_es: "Chile",
      calling_code: "+56", region: "Americas", subregion: "South America"
    )
  end

  let!(:spain) do
    Country.create!(
      iso2: "ES", iso3: "ESP", numeric_code: "724",
      name_en: "Spain", name_es: "España",
      calling_code: "+34", region: "Europe", subregion: "Southern Europe"
    )
  end

  describe "GET /api/v1/countries" do
    it "returns all countries ordered by name_en" do
      get "/api/v1/countries"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(2)
      expect(json.first.keys).to include("id", "iso2", "iso3", "name_en", "name_es")
      # orden por name_en
      expect(json.map { |c| c["name_en"] }).to eq(%w[Chile Spain])
    end
  end

  describe "GET /api/v1/countries/:id" do
    it "returns a single country" do
      get "/api/v1/countries/#{chile.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(chile.id)
      expect(json["iso2"]).to eq("CL")
    end

    it "returns 404 when not found" do
      get "/api/v1/countries/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/countries/search" do
    it "returns empty array when q is blank" do
      get "/api/v1/countries/search"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "finds by partial name (case-insensitive, en/es)" do
      get "/api/v1/countries/search", params: { q: "spa" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["iso2"]).to eq("ES")

      get "/api/v1/countries/search", params: { q: "paña" }
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["iso2"]).to eq("ES")
    end

    it "finds by iso2 / iso3 / numeric_code (exact)" do
      get "/api/v1/countries/search", params: { q: "cl" }
      expect(JSON.parse(response.body).first["id"]).to eq(chile.id)

      get "/api/v1/countries/search", params: { q: "CHL" }
      expect(JSON.parse(response.body).first["id"]).to eq(chile.id)

      get "/api/v1/countries/search", params: { q: "724" }
      expect(JSON.parse(response.body).first["id"]).to eq(spain.id)
    end
  end
end
