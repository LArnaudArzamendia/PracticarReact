class API::V1::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[show update destroy]

  def index
    posts = Post
              .includes(
                :user,
                :pictures, :videos, :audios,
                trip_location: [:trip, :location],
                pictures: :tags
              )

    posts = posts.where(trip_location_id: params[:trip_location_id]) if params[:trip_location_id].present?
    posts = posts.joins(:trip_location).where(trip_locations: { trip_id: params[:trip_id] }) if params[:trip_id].present?
    posts = posts.joins(:trip_location).where(trip_locations: { location_id: params[:location_id] }) if params[:location_id].present?

    render json: posts.map { |p| serialize_post(p) }
  end

  # GET /api/v1/posts/:id
  def show
    render json: serialize_post(@post)
  end

  # POST /api/v1/posts
  def create
    post = current_user.posts.build(post_params)
    if post.save
      render json: serialize_post(post), status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /api/v1/posts/:id
  def update
    return render json: { error: "Not authorized" }, status: :forbidden if @post.user_id != current_user.id

    if @post.update(post_params)
      render json: serialize_post(@post)
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/posts/:id
  def destroy
    return render json: { error: "Not authorized" }, status: :forbidden if @post.user_id != current_user.id

    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find_by(id: params[:id])
    render json: { error: "Post not found" }, status: :not_found unless @post
  end

  def post_params
    params.require(:post).permit(:trip_location_id, :body)
  end

  def serialize_post(p)
    {
      id: p.id,
      trip_location_id: p.trip_location_id,
      user_id: p.user_id,
      body: p.body,
      created_at: p.created_at,
      trip_location: {
        id: p.trip_location.id,
        trip_id: p.trip_location.trip_id,
        location_id: p.trip_location.location_id,
        location: {
          id: p.location.id,
          name: p.location.name,
          latitude: p.location.latitude,
          longitude: p.location.longitude
        }
      },
      pictures: p.pictures.map { |pic|
        {
          id: pic.id,
          caption: pic.caption,
          url: (pic.file.attached? ? url_for(pic.file) : nil),
          tags: pic.tags.includes(:user).map { |t|
            { id: t.id, user_id: t.user_id, handle: t.user.handle, x_frac: t.x_frac, y_frac: t.y_frac }
          }
        }
      },
      videos: p.videos.map { |vid|
        {
          id: vid.id,
          caption: vid.caption,
          url: (vid.file.attached? ? url_for(vid.file) : nil)
        }
      },
      audios: p.audios.select(:id, :caption)
    }
  end
end