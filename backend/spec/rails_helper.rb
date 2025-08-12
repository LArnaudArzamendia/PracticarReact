# spec/rails_helper.rb
ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"     # <- carga rspec-rails
require "spec_helper"     # <- ahora sí, DESPUÉS de cargar Rails

# Mantén el esquema al día
begin
  ActiveRecord::Migration.maintain_test_schema! if defined?(ActiveRecord::Migration)
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Indica que usarás ActiveRecord con RSpec
  config.use_active_record = true

  # Rails 7.1+ deprecó fixture_path (singular); usa plural:
  config.fixture_paths = [
    Rails.root.join("spec/fixtures").to_s
  ]
  # Si tienes file fixtures:
  # config.file_fixture_path = Rails.root.join("spec/fixtures/files")

  # Transacciones por ejemplo (si no usas DatabaseCleaner)
  config.use_transactional_fixtures = true

  # Inferir tipo de spec por ubicación (requests/, models/, etc.)
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include AuthHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

