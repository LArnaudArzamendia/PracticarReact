# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def destroy
    resource.destroy
    head :no_content
  end
end
