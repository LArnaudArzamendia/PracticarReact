# Dockerfile.dev
FROM node:24-alpine

# Directorio de trabajo en el contenedor
WORKDIR /app

# Copiar los archivos de configuración del proyecto
COPY package.json yarn.lock ./

# Instalar dependencias
RUN yarn install

# Copiar todos los archivos del proyecto
COPY . .

# Exponer el puerto 3000 para acceso desde el host
EXPOSE 3000

# Comando para iniciar la aplicación
CMD ["yarn", "start"]
