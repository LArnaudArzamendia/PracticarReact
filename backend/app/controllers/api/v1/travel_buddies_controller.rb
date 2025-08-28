class API::V1::TravelBuddiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :authorize_trip_owner!   # sólo el dueño del trip puede gestionar buddies
  before_action :set_travel_buddy, only: %i[update destroy]

  # GET /api/v1/trips/:trip_id/travel_buddies
  # Opcional: ?can_post=true/false
  def index
    scope = @trip.travel_buddies.includes(:user, :met_location)
    scope = scope.where(can_post: ActiveModel::Type::Boolean.new.cast(params[:can_post])) if params.key?(:can_post)

    render json: scope.as_json(
      only: %i[id trip_id user_id met_location_id met_on can_post],
      include: {
        user:         { only: %i[id email], methods: %i[handle] }, # ajusta campos según tu modelo User
        met_location: { only: %i[id name country_id] }
      }
    )
  end

  # POST /api/v1/trips/:trip_id/travel_buddies
  # Acepta:
  #  - user_id o user_handle
  #  - met_location_id o met_location: { name, country_id, latitude?, longitude? }
  #  - met_on? (YYYY-MM-DD), can_post? (bool)
  def create
    buddy_user = resolve_user!
    return if performed? # ya renderizó 404/422 dentro de resolve_user!

    return render json: { error: "You cannot add yourself as travel buddy" },
                  status: :unprocessable_content if buddy_user.id == current_user.id    

    met_loc = resolve_met_location # puede ser nil
    attrs = {
      user_id:         buddy_user.id,
      met_location_id: met_loc&.id,
      met_on:          params[:met_on],
      can_post:        params.key?(:can_post) ? ActiveModel::Type::Boolean.new.cast(params[:can_post]) : false
    }

    tb = @trip.travel_buddies.find_or_initialize_by(user_id: buddy_user.id)
    tb.assign_attributes(attrs) # idempotente: si existe, actualiza datos de encuentro / can_post

    if tb.save
      render json: tb.as_json(
        only: %i[id trip_id user_id met_location_id met_on can_post]
      ), status: (tb.previously_new_record? ? :created : :ok)
    else
      render json: { errors: tb.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: [e.message] }, status: :unprocessable_content
  end

  # PATCH/PUT /api/v1/trips/:trip_id/travel_buddies/:id
  # Permite cambiar met_on, can_post y/o met_location(_id|inline)
  def update
    met_loc = resolve_met_location
    updates = travel_buddy_params
    updates[:met_location_id] = met_loc.id if met_loc

    if @travel_buddy.update(updates)
      render json: @travel_buddy.as_json(only: %i[id trip_id user_id met_location_id met_on can_post])
    else
      render json: { errors: @travel_buddy.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /api/v1/trips/:trip_id/travel_buddies/:id
  def destroy
    @travel_buddy.destroy
    head :no_content
  end

  private

  def set_trip
    @trip = current_user.trips.find_by(id: params[:trip_id]) || Trip.find_by(id: params[:trip_id])
    render(json: { error: "Trip not found" }, status: :not_found) unless @trip
  end

  def authorize_trip_owner!
    return if @trip && @trip.user_id == current_user.id
    render json: { error: "Not authorized" }, status: :forbidden
  end

  def set_travel_buddy
    @travel_buddy = @trip.travel_buddies.find_by(id: params[:id])
    render(json: { error: "TravelBuddy not found" }, status: :not_found) unless @travel_buddy
  end

  def travel_buddy_params
    params.require(:travel_buddy).permit(:met_on, :can_post)
  end

  # ---- Resolución de usuario por user_id o user_handle ----
  def resolve_user!
    if params[:user_id].present?
      user = User.find_by(id: params[:user_id])
      return user if user
      render json: { error: "User not found" }, status: :not_found and return
    end

    if (handle = params[:user_handle]).present?
      h = handle.to_s.strip.downcase
      h = "@#{h}" unless h.start_with?("@")
      user = User.find_by(handle: h)
      return user if user
      render json: { error: "User not found" }, status: :not_found and return
    end

    render json: { error: "user_id or user_handle required" }, status: :unprocessable_content and return
  end

  # ---- Resolución de location (id o inline) ----
  def resolve_met_location
    return nil if params[:met_location_id].blank? && params[:met_location].blank?

    if params[:met_location_id].present?
      return Location.find(params[:met_location_id])
    end

    lp = params.require(:met_location).permit(:name, :country_id, :latitude, :longitude)
    raise ActiveRecord::RecordInvalid.new(Location.new), "met_location.name and country_id required" if lp[:name].blank? || lp[:country_id].blank?

    # Reutiliza tu criterio de unicidad por (country_id, normalized_name)
    # Asumiendo que Location ya normaliza name en before_validation
    Location.where(country_id: lp[:country_id])
            .where("LOWER(normalized_name) = ?", I18n.transliterate(lp[:name]).downcase.strip)
            .first_or_create!(
              name: lp[:name].to_s.strip,
              latitude: lp[:latitude],
              longitude: lp[:longitude]
            )
  end
end
