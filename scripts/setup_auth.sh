#!/usr/bin/env bash
set -euo pipefail

# ---- Settings ----
APP_DIR="${APP_DIR:-backend}"
JWT_COOKIE_NAME="${JWT_COOKIE_NAME:-app_jwt}"
FRONTEND_ORIGIN_DEV="${FRONTEND_ORIGIN_DEV:-http://localhost:3000}"
RAILS_PORT="${RAILS_PORT:-3001}"

# ---- Locate Rails app dir ----
if [ -d "$APP_DIR" ]; then
  cd "$APP_DIR"
elif [ -f "bin/rails" ]; then
  APP_DIR="."
else
  echo "ERROR: No encuentro la app Rails. Ejecuta desde la raíz (con ./backend) o define APP_DIR=."
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "ERROR: Bundler no está en PATH."
  exit 1
fi

# ---- Gemfile updates (idempotentes) ----
add_gem_line() {
  local line="$1"
  grep -qF "$line" Gemfile || echo "$line" >> Gemfile
}

# Asegura dotenv y rack-cors
add_gem_line 'gem "rack-cors"'
if ! grep -q 'dotenv-rails' Gemfile; then
  printf '%s\n' 'group :development, :test do' '  gem "dotenv-rails"' 'end' >> Gemfile
fi

# Devise + JWT + cookie2
add_gem_line 'gem "devise", "~> 4.9"'
add_gem_line 'gem "devise-jwt", "~> 0.12"'
# si existía la gema antigua, elimínala
if grep -q 'devise-jwt-cookie"' Gemfile; then
  sed -i.bak '/devise-jwt-cookie"/d' Gemfile
fi
add_gem_line 'gem "devise-jwt-cookie2", "~> 0.6.0"'

echo "-> bundle install"
bundle install

# ---- Habilitar cookies en API mode (por si faltó --cookie-store) ----
APP_CONFIG="config/application.rb"
if grep -q "config.api_only = true" "$APP_CONFIG"; then
  if ! grep -q "ActionDispatch::Cookies" "$APP_CONFIG"; then
    echo "-> Añadiendo middleware de cookies a API"
    awk '
      /class Application < Rails::Application/ {print; in_app=1; next}
      in_app && /config.api_only = true/ {
        print;
        print "    # Enable cookies & sessions in API mode";
        print "    config.middleware.use ActionDispatch::Cookies";
        print "    config.middleware.use ActionDispatch::Session::CookieStore";
        in_app=0; next
      }
      {print}
    ' "$APP_CONFIG" > "$APP_CONFIG.tmp" && mv "$APP_CONFIG.tmp" "$APP_CONFIG"
  fi
fi

# ---- Devise install ----
if [ ! -f config/initializers/devise.rb ]; then
  echo "-> rails g devise:install"
  DISABLE_SPRING=1 bin/rails g devise:install
fi

# ---- Modelo User (si no existe) ----
if [ ! -f app/models/user.rb ]; then
  echo "-> rails g devise User"
  DISABLE_SPRING=1 bin/rails g devise User
fi

# ---- Migración JTI (para revocación con JTIMatcher) ----
if ! ls db/migrate/*_add_jti_to_users.rb >/dev/null 2>&1; then
  echo "-> Creando migración add_jti_to_users"
  cat > db/migrate/$(date +%Y%m%d%H%M%S)_add_jti_to_users.rb <<'RUBY'
class AddJtiToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :jti, :string, null: false
    add_index  :users, :jti, unique: true
  end
end
RUBY
  sleep 1
fi

# ---- Parchear modelo User para JWT + cookie2 + JTIMatcher ----
if grep -q "^class User < ApplicationRecord" app/models/user.rb; then
  ruby - <<'RUBY'
path = "app/models/user.rb"
s = File.read(path)

desired = <<~DEV
  devise :database_authenticatable,
         :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_cookie_authenticatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::JTIMatcher
DEV

if s =~ /^\s*devise\b/
  # Reemplaza el bloque devise actual hasta antes de 'end'
  s.sub!(/^\s*devise\b.*?(?=^\s*end)/m, desired)
else
  # Inserta el bloque devise debajo de la clase
  s.sub!(/^class User < ApplicationRecord$/, "class User < ApplicationRecord\n#{desired.rstrip}")
end

File.write(path, s)
RUBY
fi


# ---- Config Devise: JWT + JWT cookie (cookie2) ----
# Añade bloque JWT si no existe
if ! grep -q "config.jwt do |jwt|" config/initializers/devise.rb; then
  cat >> config/initializers/devise.rb <<'RUBY'

# == Devise JWT ==
Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = ENV.fetch("DEVISE_JWT_SECRET_KEY")
    jwt.dispatch_requests = [['POST', %r{^/users/sign_in$}]]
    jwt.revocation_requests = [['DELETE', %r{^/users/sign_out$}]]
    jwt.request_formats = { user: [:json] }
  end
end
RUBY
fi

# Añade bloque JWT cookie si no existe
if ! grep -q "config.jwt_cookie do |jwt_cookie|" config/initializers/devise.rb; then
  cat >> config/initializers/devise.rb <<RUBY

# == Devise JWT Cookie (devise-jwt-cookie2) ==
Devise.setup do |config|
  config.jwt_cookie do |jwt_cookie|
    jwt_cookie.name      = ENV.fetch("JWT_COOKIE_NAME", "${JWT_COOKIE_NAME}")
    jwt_cookie.secure    = Rails.env.production?
    jwt_cookie.httponly  = true
    jwt_cookie.same_site = Rails.env.production? ? :none : :lax
    # Nota: la expiración de la cookie debe ser <= exp del JWT (configúrala si fuese necesario)
    # jwt_cookie.expires_in = 30.minutes
  end
end
RUBY
fi

# Elimina initializer antiguo si existiera
[ -f config/initializers/devise_jwt_cookie.rb ] && rm -f config/initializers/devise_jwt_cookie.rb

# ---- Rutas Devise JSON ----
if ! grep -q "devise_for :users" config/routes.rb; then
  echo 'devise_for :users, defaults: { format: :json }' >> config/routes.rb
fi

# ---- CORS (dev/test localhost:3000, prod via FRONTEND_ORIGIN) ----
if [ ! -f config/initializers/cors.rb ]; then
  cat > config/initializers/cors.rb <<'RUBY'
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.env.development? || Rails.env.test?
    allow do
      origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")
      resource "*",
        headers: :any,
        methods: %i[get post put patch delete options head],
        credentials: true
    end
  else
    allowed_origin = ENV["FRONTEND_ORIGIN"]
    if allowed_origin.present?
      allow do
        origins allowed_origin
        resource "*",
          headers: :any,
          methods: %i[get post put patch delete options head],
          credentials: true
      end
    end
  end
end
RUBY
fi

# ---- Puma: puerto 3001 por defecto ----
PUMA_CFG="config/puma.rb"
if grep -q "^port " "$PUMA_CFG"; then
  sed -i.bak -E "s/^port .*/port ENV.fetch(\"PORT\") { ${RAILS_PORT} }/" "$PUMA_CFG"
else
  echo "port ENV.fetch(\"PORT\") { ${RAILS_PORT} }" >> "$PUMA_CFG"
fi

# ---- .env (dev/test) ----
if [ ! -f .env ]; then
  cat > .env <<ENVVARS
PORT=${RAILS_PORT}
FRONTEND_ORIGIN=${FRONTEND_ORIGIN_DEV}
DEVISE_JWT_SECRET_KEY=$(openssl rand -hex 64)
JWT_COOKIE_NAME=${JWT_COOKIE_NAME}
ENVVARS
fi

# ---- Reordenar migraciones: Devise primero, JTI después ----
echo "-> Acomodando orden de migraciones (DeviseCreateUsers antes que AddJtiToUsers)"
ruby - <<'RUBY'
require "time"
dir = "db/migrate"
dev = Dir[File.join(dir, "*_devise_create_users.rb")].first
jti = Dir[File.join(dir, "*_add_jti_to_users.rb")].first

if dev && jti
  dev_ts = File.basename(dev).split('_').first
  jti_ts = File.basename(jti).split('_').first
  if jti_ts <= dev_ts
    new_ts = (Time.strptime(dev_ts, "%Y%m%d%H%M%S") + 1).strftime("%Y%m%d%H%M%S")
    new_path = File.join(dir, "#{new_ts}_add_jti_to_users.rb")
    File.rename(jti, new_path)
    puts "✔ Renombrado: #{File.basename(jti)} -> #{File.basename(new_path)}"
    jti = new_path
  else
    puts "✔ Orden ya correcto"
  end

  # Homogeneiza versión de migración a 8.0 (opcional pero prolijo)
  [dev, jti].each do |f|
    txt = File.read(f)
    if txt.include?("ActiveRecord::Migration[7.2]")
      File.write(f, txt.gsub("ActiveRecord::Migration[7.2]", "ActiveRecord::Migration[8.0]"))
      puts "✔ Actualizada versión de migración en #{File.basename(f)} a [8.0]"
    end
  end
else
  puts "⚠ No encontré ambas migraciones aún; continúo."
end
RUBY

# ---- DB migrate ----
echo "-> rails db:migrate"
DISABLE_SPRING=1 bin/rails db:migrate

# ---- Commit ----
cd ..
git add -A
git commit -m "Auth: Devise + devise-jwt + devise-jwt-cookie2 (JWT en HttpOnly cookie), CORS credenciales, Puma 3001, dotenv, cookies en API"
echo "✅ Listo. Levanta el backend con: (cd ${APP_DIR} && bin/rails s) → http://localhost:${RAILS_PORT}"

