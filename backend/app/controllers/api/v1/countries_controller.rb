# app/controllers/api/v1/countries_controller.rb
class API::V1::CountriesController < ApplicationController
  # Si tu API exige JWT globalmente, estos endpoints quedan públicos (read‑only)
  skip_before_action :authenticate_user!, only: [ :index, :show, :search ] if respond_to?(:authenticate_user!)

  FIELDS = %i[id iso2 iso3 name_en name_es numeric_code calling_code region subregion].freeze

  def index
    countries = Country.order(:name_en)
    render json: countries.as_json(only: FIELDS)
  end

  def show
    country = Country.find(params[:id])
    render json: country.as_json(only: FIELDS)
  end

  # GET /api/v1/countries/search?q=chi
  # Permite buscar por nombre (en/es) o códigos iso2/iso3/numeric_code
  def search
    term = params[:q].to_s.strip
    if term.blank?
      render json: [], status: :ok and return
    end

    countries = Country.where(
      arel_name_en_matches(term)
        .or(arel_name_es_matches(term))
        .or(Country.arel_table[:iso2].lower.eq(term.downcase))
        .or(Country.arel_table[:iso3].lower.eq(term.downcase))
        .or(Country.arel_table[:numeric_code].eq(term))
    ).order(:name_en)

    render json: countries.as_json(only: FIELDS)
  end

  private

  # Usamos LOWER + LIKE para portabilidad (SQLite / Postgres)
  def arel_name_en_matches(term)
    t = Country.arel_table
    t[:name_en].lower.matches("%#{sanitize_like(term.downcase)}%")
  end

  def arel_name_es_matches(term)
    t = Country.arel_table
    t[:name_es].lower.matches("%#{sanitize_like(term.downcase)}%")
  end

  # Escapa comodines para LIKE
  def sanitize_like(str)
    str.gsub(/[\\%_]/) { |m| "\\#{m}" }
  end
end
