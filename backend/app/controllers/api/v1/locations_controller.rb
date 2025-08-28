# app/controllers/api/v1/locations_controller.rb
class API::V1::LocationsController < ApplicationController
  before_action :set_location, only: %i[show update destroy]

  # GET /api/v1/locations
  def index
    locations = Location.all
    render json: locations
  end

  # GET /api/v1/locations/:id
  def show
    render json: @location
  end

  # POST /api/v1/locations
  def create
    location = Location.new(location_params)
    if location.save
      render json: location, status: :created
    else
      render json: { errors: location.errors.full_messages }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /api/v1/locations/:id
  def update
    if @location.update(location_params)
      render json: @location
    else
      render json: { errors: @location.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/locations/:id
  def destroy
    @location.destroy
    head :no_content
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:country_id, :name, :latitude, :longitude, :photo)
  end
end
