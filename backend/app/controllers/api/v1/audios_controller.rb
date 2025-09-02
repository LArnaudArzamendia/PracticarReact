class API::V1::AudiosController < API::V1::BaseMediaController
  private
  def model_class
    Audio
  end

  def singular_param_key
    :audio
  end

  def attachment_name
    :file    # has_one_attached :file
  end
end
