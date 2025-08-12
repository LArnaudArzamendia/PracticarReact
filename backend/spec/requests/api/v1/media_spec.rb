require "rails_helper"

RSpec.shared_examples "media API" do |resource, factory|
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:post_rec) { create(:post, user: user) }

  def auth_cookie(user)
    post "/users/sign_in",
        params: { user: { email: user.email, password: "password123" } }

    set_cookie = Array(response.get_header("Set-Cookie"))

    raw_cookie = set_cookie.find { |c| c.start_with?("app_jwt=") }
    raise "JWT cookie not found in #{set_cookie.inspect}" unless raw_cookie

    token = raw_cookie.match(/app_jwt=([^;]+)/)[1]
    "app_jwt=#{token}"
  end

  it "creates a #{resource} for own post" do
    cookie = auth_cookie(user)  
    expect {
      post "/api/v1/#{resource}",
           params: { resource.singularize => { post_id: post_rec.id, caption: "hola" } },
           headers: { "Cookie" => cookie }
    }.to change(factory.classify.constantize, :count).by(1)

    expect(response).to have_http_status(:created)
  end

  it "filters #{resource} by post_id" do
    cookie = auth_cookie(user)
    create_list(factory, 2, post: post_rec)
    get "/api/v1/#{resource}", params: { post_id: post_rec.id }, headers: { "Cookie" => cookie }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body).size).to eq(2)
  end
end

RSpec.describe "Media API", type: :request do
  include_examples "media API", "pictures", "picture"
  include_examples "media API", "videos",   "video"
  include_examples "media API", "audios",   "audio"
end
