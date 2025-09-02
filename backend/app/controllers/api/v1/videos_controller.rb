class API::V1::VideosController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/videos?post_id=...
  def index
    scope = Video.all
    scope = scope.where(post_id: params[:post_id]) if params[:post_id].present?
    render json: scope.map { |v| serialize(v) }
  end

  # POST /api/v1/videos (multipart)
  def create
    post = Post.find(params[:post_id])
    video = post.videos.build(caption: params[:caption])
    video.file.attach(params[:file]) if params[:file].present?
    video.save!
    render json: serialize(video), status: :created
  end

  # DELETE /api/v1/videos/:id
  def destroy
    Video.find(params[:id]).destroy
    head :no_content
  end

  private

  def serialize(v)
    {
      id: v.id,
      post_id: v.post_id,
      caption: v.caption,
      url: (v.file.attached? ? url_for(v.file) : nil)
    }
  end
end