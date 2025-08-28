class API::V1::TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [ :show, :update, :destroy ]

  def index
    trips = current_user.trips.order(created_at: :desc)
    render json: trips.as_json(only: [ :id, :title, :description, :starts_on, :ends_on, :public ])
  end

  def show
    render json: @trip.as_json(only: [ :id, :title, :description, :starts_on, :ends_on, :public ])
  end

  def create
    trip = current_user.trips.build(trip_params)
    if trip.save
      render json: trip.as_json(only: [ :id, :title, :description, :starts_on, :ends_on, :public ]), status: :created
    else
      render json: { errors: trip.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @trip.update(trip_params)
      render json: @trip.as_json(only: [ :id, :title, :description, :starts_on, :ends_on, :public ])
    else
      render json: { errors: @trip.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @trip.destroy
    head :no_content
  end

  private

  def set_trip
    @trip = current_user.trips.find_by(id: params[:id])
    render json: { error: "Trip not found" }, status: :not_found unless @trip
  end

  def trip_params
    params.require(:trip).permit(:title, :description, :starts_on, :ends_on, :public)
  end
end
