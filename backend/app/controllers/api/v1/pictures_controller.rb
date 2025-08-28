class API::V1::PicturesController < API::V1::BaseMediaController
  private
  def model_class
    Picture
  end
  
  def singular_param_key
    :picture
  end

  def attachment_name
    :image   # has_one_attached :image
  end
end
