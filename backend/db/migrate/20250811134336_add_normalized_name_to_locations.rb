# db/migrate/20250811_add_normalized_name_to_locations.rb
class AddNormalizedNameToLocations < ActiveRecord::Migration[8.0]
  def up
    add_column :locations, :normalized_name, :string

    # Backfill usando el modelo (aceptable aquí; evita dependencias SQL no portables)
    say_with_time "Backfilling normalized_name for locations" do
      Location.reset_column_information
      Location.find_each do |loc|
        loc.update_columns(normalized_name: normalize(loc.name))
      end
    end

    add_index :locations, [:country_id, :normalized_name],
              unique: true, name: "idx_locations_country_normname_unique"
  end

  def down
    remove_index :locations, name: "idx_locations_country_normname_unique"
    remove_column :locations, :normalized_name
  end

  private

  # Normalización 100% Ruby, portable.
  def normalize(str)
    return nil if str.nil?
    I18n.available_locales # asegura I18n cargado
    I18n.transliterate(str.to_s).downcase.strip
  end
end
