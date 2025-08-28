# spec/requests/api/v1/tags_spec.rb
require "rails_helper"

RSpec.describe "API::V1::Tags", type: :request do
  let!(:owner)   { create(:user, password: "password123", password_confirmation: "password123") }
  let!(:headers) { auth_headers_for(owner, password: "password123") }

  let!(:post_rec) { create(:post, user: owner) }
  let!(:picture)  { create(:picture, post: post_rec) }

  describe "GET /api/v1/pictures/:picture_id/tags" do
    before do
      create(:tag, picture: picture, user: create(:user))
      create(:tag, picture: picture, user: create(:user))
    end

    it "lista los tags con el user embebido" do
      get "/api/v1/pictures/#{picture.id}/tags", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.first["user"]).to include("id", "email", "handle")
    end
  end

  describe "POST /api/v1/pictures/:picture_id/tags", :auth do
    it "crea un tag por user_id" do
      buddy = create(:user)
      expect {
        post "/api/v1/pictures/#{picture.id}/tags",
             params: { tag: { user_id: buddy.id } },
             headers: headers
      }.to change(Tag, :count).by(1)
      expect(response).to have_http_status(:ok)
    end

    it "crea un tag por user_handle" do
      buddy = create(:user, handle: "@buddy_#{SecureRandom.hex(2)}")
      expect {
        post "/api/v1/pictures/#{picture.id}/tags",
             params: { tag: { user_handle: buddy.handle } },
             headers: headers
      }.to change(Tag, :count).by(1)
      expect(response).to have_http_status(:ok)
    end

    it "es idempotente: no duplica si ya existe" do
      buddy = create(:user)
      create(:tag, picture: picture, user: buddy)
      expect {
        post "/api/v1/pictures/#{picture.id}/tags",
             params: { tag: { user_id: buddy.id } },
             headers: headers
      }.not_to change(Tag, :count)
      expect(response).to have_http_status(:ok)
    end

    it "retorna 404 si el user_handle no existe" do
      post "/api/v1/pictures/#{picture.id}/tags",
           params: { tag: { user_handle: "@no_existe" } },
           headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it "forbidden si no soy dueño del post/picture" do
      intruder = create(:user, password: "p4ssw0rd", password_confirmation: "p4ssw0rd")

      delete "/users/sign_out" # limpia cookie del actual (owner)
      intruder_headers = auth_headers_for(intruder, password: "p4ssw0rd")
      buddy = create(:user)

      post "/api/v1/pictures/#{picture.id}/tags",
           params: { tag: { user_id: buddy.id } },
           headers: intruder_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/pictures/:picture_id/tags/:id" do
    it "elimina un tag" do
      tag = create(:tag, picture: picture, user: create(:user))
      expect {
        delete "/api/v1/pictures/#{picture.id}/tags/#{tag.id}", headers: headers
      }.to change(Tag, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "404 si tag no pertenece a la picture" do
      other_pic = create(:picture, post: post_rec)
      tag = create(:tag, picture: other_pic, user: create(:user))
      delete "/api/v1/pictures/#{picture.id}/tags/#{tag.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
