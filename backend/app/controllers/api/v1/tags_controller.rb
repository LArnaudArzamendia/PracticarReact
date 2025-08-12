# app/controllers/api/v1/tags_controller.rb
class API::V1::TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_picture

  def index
    tags = @picture.tags.includes(:user)
    render json: tags.as_json(include: { user: { only: [:id, :email, :handle, :name] } }), status: :ok
  end

  def create
    # 🔒 dueñ@ del post/picture solamente
    unless owns_picture?
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    user = resolve_user!
    tag  = @picture.tags.find_or_initialize_by(user: user)
    tag.assign_attributes(tag_params.slice(:x_frac, :y_frac))

    if tag.save
      render json: tag.as_json(include: { user: { only: [:id, :email, :handle, :name] } }), status: :ok
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    # 🔒 dueñ@ del post/picture solamente
    unless owns_picture?
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    tag = @picture.tags.find_by!(id: params[:id])
    tag.destroy!
    head :no_content
  end

  private

  def set_picture
    @picture = Picture.find(params[:picture_id])
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

  def owns_picture?
    @picture&.post&.user_id == current_user.id
  end
end
