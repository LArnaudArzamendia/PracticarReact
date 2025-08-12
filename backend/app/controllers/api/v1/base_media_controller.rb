class API::V1::BaseMediaController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resource, only: %i[show update destroy]

  # GET /api/v1/<media>?post_id=...
  def index
    scope = model_class.all
    scope = scope.where(post_id: params[:post_id]) if params[:post_id].present?

    render json: scope.as_json(only: %i[id post_id caption created_at])
  end

  # GET /api/v1/<media>/:id
  def show
    render json: @resource.as_json(only: %i[id post_id caption created_at])
  end

  # POST /api/v1/<media>
  # Params: { <singular>: { post_id, caption, file? } }
  def create
    resource = model_class.new(resource_params)

    # autorización básica: el post debe ser del current_user
    return forbid! unless owns_post?(resource.post_id)

    if resource.save
      attach_file(resource)
      render json: resource.as_json(only: %i[id post_id caption created_at]),
              status: :created
    else
      render json: { errors: resource.errors.full_messages },
              status: :unprocessable_content
    end
  end

  # PATCH/PUT /api/v1/<media>/:id
  def update
    return forbid! unless owns_post?(@resource.post_id)

    if @resource.update(resource_params.except(:file))
      attach_file(@resource) # opcional: reemplazar archivo si viene file
      render json: @resource.as_json(only: %i[id post_id caption created_at])
    else
      render json: { errors: @resource.errors.full_messages },
              status: :unprocessable_content
    end
  end

  # DELETE /api/v1/<media>/:id
  def destroy
    return forbid! unless owns_post?(@resource.post_id)

    @resource.destroy
    head :no_content
  end

  private

  # >>> Métodos que parametrizan las subclases <<<
  def model_class
    raise NotImplementedError
  end

  def singular_param_key
    # :picture, :video o :audio en subclases
    raise NotImplementedError
  end

  def attachment_name
    # :image, :video_file, :audio_file, etc. si usas ActiveStorage
    nil
  end

  # -----------------------------------------------

  def set_resource
    @resource = model_class.find_by(id: params[:id])
    render json: { error: "#{model_class.name} not found" }, status: :not_found unless @resource
  end

  def resource_params
    params.require(singular_param_key).permit(:post_id, :caption, :file)
  end

  def attach_file(resource)
    return unless attachment_name && params[singular_param_key][:file].present?

    uploaded = params[singular_param_key][:file] # ActionDispatch::Http::UploadedFile
    resource.public_send(attachment_name).attach(uploaded)
  end

  def owns_post?(post_id)
    post = Post.find_by(id: post_id)
    post && post.user_id == current_user.id
  end

  def forbid!
    render json: { error: "Not authorized" }, status: :forbidden
  end
end
