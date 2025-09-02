class API::V1::PicturesController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/pictures?post_id=...
  def index
    scope = Picture.all
    scope = scope.where(post_id: params[:post_id]) if params[:post_id].present?
    render json: scope.map { |p| serialize(p) }
  end

  # POST /api/v1/pictures (multipart)
  def create
    post = Post.find(params[:post_id])
    pic = post.pictures.build(caption: params[:caption])
    pic.file.attach(params[:file]) if params[:file].present?
    pic.save!
    render json: serialize(pic), status: :created
  end

  # DELETE /api/v1/pictures/:id
  def destroy
    Picture.find(params[:id]).destroy
    head :no_content
  end

  private

  def serialize(p)
    {
      id: p.id,
      post_id: p.post_id,
      caption: p.caption,
      url: (p.file.attached? ? url_for(p.file) : nil),
      tags: p.tags.includes(:user).map { |t| { id: t.id, user_id: t.user_id, handle: t.user.handle, x_frac: t.x_frac, y_frac: t.y_frac } }
    }
  end
end