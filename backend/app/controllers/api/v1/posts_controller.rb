# app/controllers/api/v1/posts_controller.rb
class API::V1::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[show update destroy]

  # GET /api/v1/posts
  # Filtros soportados:
  #   ?trip_id=1            -> todos los posts de un viaje
  #   ?location_id=2        -> todos los posts de una ubicación
  #   ?trip_location_id=10  -> posts de una trip_location específica
  def index
    posts = Post.includes(:pictures, :videos, :audios, trip_location: %i[trip location])

    if params[:trip_location_id].present?
      posts = posts.where(trip_location_id: params[:trip_location_id])
    end

    if params[:trip_id].present?
      posts = posts.joins(:trip_location).where(trip_locations: { trip_id: params[:trip_id] })
    end

    if params[:location_id].present?
      posts = posts.joins(:trip_location).where(trip_locations: { location_id: params[:location_id] })
    end

    render json: posts.as_json(
      only: %i[id trip_location_id user_id body created_at],
      include: {
        trip_location: {
          only: %i[id trip_id location_id],
          include: {
            trip: { only: %i[id title starts_on ends_on] },
            location: { only: %i[id name country_id] }
          }
        },
        pictures: { only: %i[id caption] },
        videos:   { only: %i[id caption] },
        audios:   { only: %i[id caption] }
      }
    )
  end

  # GET /api/v1/posts/:id
  def show
    render json: @post.as_json(
      only: %i[id trip_location_id user_id body created_at],
      include: {
        trip_location: {
          only: %i[id trip_id location_id],
          include: {
            trip: { only: %i[id title starts_on ends_on] },
            location: { only: %i[id name country_id] }
          }
        },
        pictures: { only: %i[id caption] },
        videos:   { only: %i[id caption] },
        audios:   { only: %i[id caption] }
      }
    )
  end

  # POST /api/v1/posts
  def create
    post = current_user.posts.build(post_params)
    if post.save
      render json: post.as_json(
        only: %i[id trip_location_id user_id body created_at],
        include: {
          trip_location: {
            only: %i[id trip_id location_id],
            include: {
              trip: { only: %i[id title starts_on ends_on] },
              location: { only: %i[id name country_id] }
            }
          },
          pictures: { only: %i[id caption] },
          videos:   { only: %i[id caption] },
          audios:   { only: %i[id caption] }
        }
      ), status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /api/v1/posts/:id
  def update
    return render json: { error: "Not authorized" }, status: :forbidden if @post.user_id != current_user.id

    if @post.update(post_params)
      render json: @post.as_json(
        only: %i[id trip_location_id user_id body created_at],
        include: {
          trip_location: {
            only: %i[id trip_id location_id],
            include: {
              trip: { only: %i[id title starts_on ends_on] },
              location: { only: %i[id name country_id] }
            }
          },
          pictures: { only: %i[id caption] },
          videos:   { only: %i[id caption] },
          audios:   { only: %i[id caption] }
        }
      )
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
end
