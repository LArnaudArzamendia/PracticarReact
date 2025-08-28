class Users::SessionsController < Devise::SessionsController
  include ActionController::MimeResponds
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: { ok: true }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end
end
