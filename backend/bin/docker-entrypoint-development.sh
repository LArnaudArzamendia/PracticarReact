#!/usr/bin/env bash
set -e

# Instala gems si faltan
bundle check || bundle install

# Elimina el archivo server.pid existente
rm -f /app/tmp/pids/server.pid

# Ejecuta seeds (puedes cambiar a db:prepare si quieres crear/migrar+seed)
bundle exec rails db:seed

# Ejecuta el comando pasado al contenedor
exec "$@"
