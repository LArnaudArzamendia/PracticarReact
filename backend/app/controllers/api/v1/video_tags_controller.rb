class API::V1::VideoTagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_video

  def index
    tags = @video.video_tags.includes(:user)
    render json: tags.as_json(include: { user: { only: [:id, :email, :handle, :name] } }), status: :ok
  end

  def create
    # 🔒 dueñ@ del post/video solamente
    unless owns_video?
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    user = resolve_user!
    unless allowed_to_tag_user?(user)
      render json: { error: "User is not a travel buddy for this trip" }, status: :unprocessable_content
      return
    end

    tag  = @video.video_tags.find_or_initialize_by(user: user)
    tag.assign_attributes(tag_params.slice(:x_frac, :y_frac))

    if tag.save
      render json: tag.as_json(include: { user: { only: [:id, :email, :handle, :name] } }), status: :ok
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    # 🔒 dueñ@ del post/video solamente
    unless owns_video?
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    tag = @video.video_tags.find_by!(id: params[:id])
    tag.destroy!
    head :no_content
  end

  private

  def set_video
    @video = Video.find(params[:video_id])
  end

  def tag_params
    params.require(:tag).permit(:user_id, :user_handle, :x_frac, :y_frac)
  end

  def resolve_user!
    if tag_params[:user_id].present?
      User.find(tag_params[:user_id])
    elsif tag_params[:user_handle].present?
      User.find_by!(handle: tag_params[:user_handle])
    else
      raise ActiveRecord::RecordNotFound, "user_id or user_handle required"
    end
  end

  def owns_video?
    @video&.post&.user_id == current_user.id
  end

  def allowed_to_tag_user?(user)
    return false unless @video&.post
    return true if user.id == @video.post.user_id
    trip = @video.post.trip
    return false unless trip
    trip.buddies.exists?(id: user.id)
  end
end

