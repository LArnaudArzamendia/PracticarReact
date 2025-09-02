# app/controllers/api/v1/users_controller.rb
class API::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/users/search?handle=foo
  def search
    q = params[:handle].to_s.delete_prefix('@').strip
    return render json: [] if q.blank?

    # Escapa comodines para LIKE
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"

    adapter = ActiveRecord::Base.connection.adapter_name.downcase

    users =
      if adapter.include?('postgres')
        # Postgres: ILIKE
        User.where('handle ILIKE ?', pattern)
      else
        # SQLite / otros: LOWER + LIKE (o COLLATE NOCASE)
        User.where('LOWER(handle) LIKE ?', pattern.downcase)
        # Alternativa equivalente:
        # User.where('handle LIKE ? COLLATE NOCASE', pattern)
      end

    users = users
              .limit(20)
              .select(:id, :email, :handle, :country_id, :created_at)

    render json: users
  end

  # GET /api/v1/users/:id
  def show
    user = User.find(params[:id])
    trips = user.trips.where(public: true)
                .order(created_at: :desc)
                .select(:id, :title, :description, :starts_on, :ends_on)
    render json: {
      user: user.slice(:id, :email, :handle, :country_id, :created_at),
      public_trips: trips
    }
  end
end