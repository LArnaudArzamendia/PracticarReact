class API::V1::TagsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/pictures/:picture_id/tags
  def index
    picture = Picture.find(params[:picture_id])
    render json: picture.tags.includes(:user).map { |t|
      { id: t.id, user_id: t.user_id, handle: t.user.handle, x_frac: t.x_frac, y_frac: t.y_frac }
    }
  end

  # POST /api/v1/pictures/:picture_id/tags
  def create
    picture = Picture.find(params[:picture_id])
    tag = picture.tags.create!(tag_params)
    render json: { id: tag.id, user_id: tag.user_id, handle: tag.user.handle, x_frac: tag.x_frac, y_frac: tag.y_frac }, status: :created
  end

  # DELETE /api/v1/pictures/:picture_id/tags/:id
  def destroy
    picture = Picture.find(params[:picture_id])
    tag = picture.tags.find(params[:id])
    tag.destroy
    head :no_content
  end

  private

  def tag_params
    params.require(:tag).permit(:user_id, :x_frac, :y_frac)
  end
end
