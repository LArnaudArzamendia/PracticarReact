# app/controllers/api/v1/trip_locations_controller.rb
class API::V1::TripLocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_trip_location, only: %i[update destroy]

  # GET /api/v1/trips/:trip_id/trip_locations
  def index
    tls = @trip.trip_locations.order(:position)
    render json: tls.as_json(only: %i[id trip_id location_id position visited_at])
  end

  # POST /api/v1/trips/:trip_id/trip_locations
  # Params aceptados:
  #   - location_id
  #   - o bien location: { name, country_id, latitude?, longitude? }
  #   - visited_at? (ISO8601)
  def create
    location = find_or_create_location!
    tl = @trip.trip_locations.find_by(location_id: location.id)

    if tl
      # Idempotencia: ya existe para este trip y location
      return render json: tl.as_json(only: %i[id trip_id location_id position visited_at]), status: :ok
    end

    tl = @trip.trip_locations.new(
      location_id: location.id,
      position: next_position_for(@trip),
      visited_at: permitted_visited_at
    )

    if tl.save
      render json: tl.as_json(only: %i[id trip_id location_id position visited_at]), status: :created
    else
      render json: { errors: tl.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [e.message] }, status: :unprocessable_content
  end

  # PATCH/PUT /api/v1/trips/:trip_id/trip_locations/:id
  # Permite, por ejemplo, actualizar visited_at o reordenar (position)
  def update
    if @trip_location.update(trip_location_params)
      render json: @trip_location.as_json(only: %i[id trip_id location_id position visited_at])
    else
      render json: { errors: @trip_location.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/trips/:trip_id/trip_locations/:id
  def destroy
    @trip_location.destroy
    head :no_content
  end

  private

  def set_trip
    @trip = current_user.trips.find_by(id: params[:trip_id])
    render(json: { error: "Trip not found" }, status: :not_found) unless @trip
  end

  def set_trip_location
    @trip_location = @trip.trip_locations.find_by(id: params[:id])
    render(json: { error: "TripLocation not found" }, status: :not_found) unless @trip_location
  end

  def trip_location_params
    params.require(:trip_location).permit(:position, :visited_at)
  end

  def location_inline_params
    params.fetch(:location, {}).permit(:name, :country_id, :latitude, :longitude)
  end

  def permitted_visited_at
    params[:visited_at] || params.dig(:trip_location, :visited_at)
  end

  def next_position_for(trip)
    (trip.trip_locations.maximum(:position) || 0) + 1
  end

  # Crea o encuentra la Location:
  # - si viene location_id, la usa (y valida pertenencia de country si quieres)
  # - si viene location{name,country_id,...}, hace find_or_create_by! por (country_id, name)
  def find_or_create_location!
    if params[:location_id].present?
      return Location.find(params[:location_id])
    end

    lp = location_inline_params
    raise ActiveRecord::RecordInvalid.new(Location.new),
          "location.name and location.country_id required" if lp[:name].blank? || lp[:country_id].blank?

    norm = I18n.transliterate(lp[:name].to_s).downcase.strip

    # Busca por country + normalized_name
    location = Location.find_by(country_id: lp[:country_id], normalized_name: norm)
    return location if location

    # Creación atómica apoyada en índice único (maneja carreras)
    Location.create_or_find_by!(country_id: lp[:country_id], normalized_name: norm) do |loc|
      loc.name      = lp[:name].to_s.strip
      loc.latitude  = lp[:latitude]
      loc.longitude = lp[:longitude]
    end
  end
end
