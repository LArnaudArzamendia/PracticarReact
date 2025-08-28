class API::V1::VideosController < API::V1::BaseMediaController
  private
  def model_class
    Video
  end

  def singular_param_key
    :video
  end

  def attachment_name
    :file
  end
end
