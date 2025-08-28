
# Documentación de la API - Proyecto TravelLog

1. [Introducción](#1-introducción)
2. [Autenticación y Seguridad](#2-autenticación-y-seguridad)
3. [Convenciones de la API](#3-convenciones-de-la-api)
4. [Recursos y Endpoints](#4-recursos-y-endpoints)
   - [Usuarios](#41-usuarios-users)
   - [Países](#42-países-countries)
   - [Viajes](#43-viajes-trips)
   - [Ubicaciones](#44-ubicaciones-locations)
   - [Publicaciones](#45-publicaciones-posts)
   - [Imágenes](#46-imágenes-pictures)
   - [Videos](#47-videos-videos)
   - [Audios](#48-audios-audios)
   - [Etiquetas](#49-etiquetas-tags)
   - [Compañeros de viaje](#410-compañeros-de-viaje-travel_buddies)
5. [Ejemplos de uso con Postman](#5-ejemplos-de-uso-con-postman)
6. [Manejo de Errores](#6-manejo-de-errores)
7. [Notas para Desarrolladores](#7-notas-para-desarrolladores)

## 1. Introducción

### Propósito de esta documentación
Este documento describe el uso de la **API de backend** del proyecto *TravelLog*, desarrollada como parte del proyecto del curso.  
Su objetivo es guiar a los estudiantes en la interacción con los distintos endpoints expuestos por la aplicación Rails, de modo que puedan:
- Comprender la estructura y comportamiento de la API.
- Autenticarse y gestionar sesiones de usuario.
- Realizar operaciones CRUD (crear, leer, actualizar, eliminar) sobre los recursos del dominio.
- Integrar esta API con el cliente frontend desarrollado por cada grupo.
- Realizar pruebas y depuración de la API usando herramientas como **Postman** o scripts personalizados.

### Descripción general de la API

La API implementa la lógica de negocio y el modelo de dominio para la aplicación TravelLog.  
Entre sus funciones principales se incluyen:

- **Gestión de usuarios**: registro, autenticación y manejo de perfiles.
- **Gestión de viajes**: creación, modificación y consulta de viajes personales o compartidos.
- **Gestión de ubicaciones y contenido**: registro de localizaciones visitadas, publicaciones (texto, imágenes, videos, audios) y etiquetado de usuarios.
- **Interacción social**: invitación y administración de compañeros de viaje (*travel buddies*), menciones y etiquetas en medios.

Todas las interacciones con la API se realizan mediante **HTTP** usando solicitudes y respuestas en formato **JSON**.  
La API está diseñada para ser consumida por un frontend desarrollado en **React** (o cualquier otro cliente compatible con HTTP/JSON) y no incluye vistas HTML, ya que la aplicación Rails fue generada en modo API.

### Tecnologías utilizadas
La aplicación backend utiliza las siguientes tecnologías y componentes:
- **Ruby on Rails 8** en modo API: framework de desarrollo backend.
- **Devise** y **Devise-JWT**: para autenticación de usuarios mediante JSON Web Tokens.
- **ActiveStorage**: para la gestión de archivos multimedia (imágenes, videos y audios) asociados a las publicaciones.
- **RSpec**: para pruebas unitarias y de integración.
- **PostgreSQL** (u otra base de datos compatible con ActiveRecord) como sistema de persistencia.
- **Docker Compose** (opcional): para despliegue en ambiente de desarrollo de backend y frontend.

### URL base de la API en entorno de desarrollo
En el despliegue de desarrollo, la API se expone de la siguiente forma:

## 2. Autenticación y Seguridad

### Mecanismo de autenticación
La API utiliza **autenticación basada en JSON Web Tokens (JWT)** encapsulados en **cookies HTTP-only** para mayor seguridad.  
Este esquema evita que el token pueda ser accedido desde JavaScript en el navegador, reduciendo el riesgo de ataques XSS.

El flujo típico es:

1. El usuario se registra o inicia sesión.
2. El backend genera un JWT y lo envía en una cookie HTTP-only.
3. Las solicitudes posteriores incluyen automáticamente la cookie en el navegador, o bien, el token puede enviarse manualmente en el header `Authorization: Bearer <token>` en clientes como Postman.
4. El token expira automáticamente después de **24 horas** (valor por defecto configurable en `config/initializers/devise.rb`).

---

### Registro de usuario

**Endpoint:** `POST /api/v1/signup`
**Descripción:** Crea una nueva cuenta de usuario.

**Cuerpo de la solicitud (JSON):**
```json
{
  "user": {
    "first_name": "Juan",
    "last_name": "Pérez",
    "handle": "@juanp",
    "email": "juan@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "country_id": 1
  }
}
```

**Respuesta exitosa (201 Created):**

```json
{
  "status": "created",
  "user": {
    "id": 12,
    "first_name": "Juan",
    "last_name": "Pérez",
    "handle": "@juanp",
    "email": "juan@example.com",
    "country_id": 1,
    "created_at": "2025-08-11T14:25:00Z"
  }
}
```
Posibles errores:

* 422 Unprocessable Entity: datos inválidos o correo ya registrado.
* 400 Bad Request: formato de datos incorrecto.

### Inicio de Sesión

**Endpoint:** `POST /api/v1/login`
**Descripción:** Autentica al usuario y devuelve un JWT válido en una cookie HTTP-only.

**Cuerpo de la solicitud (JSON):**
```json
{
  "user": {
    "email": "juan@example.com",
    "password": "password123"
  }
}
```

**Respuesta exitosa (200 OK):**

```json
{
  "status": "ok",
  "token": "<jwt_token>"
}
```

**Nota:** El campo `token` puede omitirse en producción si solo se usa la cookie para el manejo de sesiones.

### Cierre de sesión

**Endpoint:** `DELETE /api/v1/logout`
**Descripción:** Invalida el token actual y limpia la cookie HTTP-only.

**Cuerpo de la solicitud (JSON):**
```json
{
  "user": {
    "email": "juan@example.com",
    "password": "password123"
  }
}
```

**Respuesta exitosa (200 OK):**

```json
{
  "status": "logged_out"
}
```

**Posibles errores:**

* 401 Unauthorized: si el token no es válido o ya expiró.

### Manejo de errores de autenticación

Las respuestas de error relacionadas con autenticación tienen el formato:

```json
{
  "error": "Mensaje de error"
}
```

Ejemplos:

Token inválido o expirado:

```json
{ "error": "Invalid or expired token" }
```

Sin token presente:

```json
{ "error": "You need to sign in or sign up before continuing." }
```

### Caducidad de Tokens

* Tiempo de expiración por defecto: 24 horas.
* Configurable en:
```ruby
# config/initializers/devise.rb
config.jwt.expiration_time = 24.hours.to_i
```
* Después de expirar, cualquier solicitud protegida devolverá `401 Unauthorized` y será necesario iniciar sesión nuevamente.

## 3. Convenciones de la API

### Formato de solicitudes y respuestas

* **Formato JSON:** todas las solicitudes que envían datos al servidor (POST, PUT, PATCH) deben usar el formato JSON.
* El encabezado `Content-Type: application/json` es obligatorio cuando se envían datos en el cuerpo.
* Todas las respuestas de la API, tanto exitosas como de error, se devuelven en formato JSON.

Ejemplo de solicitud:

```http
POST /api/v1/trips HTTP/1.1
Host: localhost:3001
Content-Type: application/json

{
  "trip": {
    "title": "Vacaciones en el sur",
    "description": "Ruta por la Patagonia",
    "starts_on": "2025-12-15",
    "ends_on": "2026-01-05"
  }
}
```

Ejemplo de respuesta exitosa:

```json
{
  "id": 3,
  "title": "Vacaciones en el sur",
  "description": "Ruta por la Patagonia",
  "starts_on": "2025-12-15",
  "ends_on": "2026-01-05",
  "created_at": "2025-08-11T14:32:00Z"
}
```

Ejemplo de respuesta de error:

```json
{
  "error": "Title can't be blank"
}
```

---

### Convención de URLs y versionado

* Todas las rutas de la API se agrupan bajo el prefijo `/api/v1`.
* Este versionado (`v1`) permite mantener compatibilidad con clientes en caso de cambios futuros.
* Las URLs utilizan nombres de recursos en plural siguiendo la convención REST.

Ejemplos:

* `GET /api/v1/users`
* `POST /api/v1/trips`
* `GET /api/v1/locations/15`

---

### Códigos de estado HTTP comunes

* **200 OK** – Solicitud exitosa (GET, PUT, PATCH, DELETE).
* **201 Created** – Recurso creado exitosamente (POST).
* **204 No Content** – Solicitud exitosa sin contenido en la respuesta.
* **400 Bad Request** – Solicitud malformada o parámetros inválidos.
* **401 Unauthorized** – Falta autenticación o token inválido.
* **403 Forbidden** – Usuario autenticado pero sin permisos para la acción.
* **404 Not Found** – Recurso no encontrado.
* **422 Unprocessable Entity** – Error de validación de datos.
* **500 Internal Server Error** – Error inesperado en el servidor.

---

### Autenticación mediante cookies HTTP-only

* La API está diseñada para encapsular el token JWT en **cookies HTTP-only**.
* Esto evita el uso de `localStorage` o `sessionStorage` y protege contra ataques XSS.
* Los navegadores incluirán automáticamente la cookie en las solicitudes al mismo dominio y puerto.
* El endpoint de inicio de sesión (`POST /api/v1/login`) **no** retorna el JWT en el cuerpo de la respuesta; únicamente lo envía como cookie HTTP-only.
* Por lo tanto, no es posible usar el encabezado `Authorization: Bearer <token>` en Postman a menos que se extraiga el token desde la cookie manualmente, lo que no es el flujo recomendado.
* En pruebas con Postman, se debe habilitar el manejo de cookies y realizar las solicitudes dentro de la misma sesión para que la cookie sea enviada automáticamente.

---

### Convenciones adicionales

* Fechas y horas se devuelven en formato ISO 8601 (UTC).
* Campos booleanos (`true`/`false`) siguen el estándar JSON.
* Listas paginadas incluirán metadatos de paginación si se implementa soporte.
* Errores de validación incluyen un hash con el campo y los mensajes asociados.

## 4. Recursos y Endpoints

### 4.1 Usuarios (`/users`)

#### **POST** `/users` — Registro de usuario

**Descripción:** Crea una nueva cuenta de usuario en el sistema.

**Cuerpo de la solicitud (JSON):**

```json
{
  "user": {
    "first_name": "Juan",
    "last_name": "Pérez",
    "handle": "@juanp",
    "email": "juan@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "country_id": 1
  }
}
```

**Respuesta exitosa (201 Created):**

```json
{
  "status": "created",
  "user": {
    "id": 12,
    "first_name": "Juan",
    "last_name": "Pérez",
    "handle": "@juanp",
    "email": "juan@example.com",
    "country_id": 1,
    "created_at": "2025-08-11T14:25:00Z"
  }
}
```

**Errores comunes:**

* `422 Unprocessable Entity`: datos inválidos o correo ya registrado.
* `400 Bad Request`: formato de datos incorrecto.

---

#### **POST** `/users/sign_in` — Autenticación

**Descripción:** Autentica al usuario y envía el token JWT como cookie HTTP-only.

**Cuerpo de la solicitud (JSON):**

```json
{
  "user": {
    "email": "juan@example.com",
    "password": "password123"
  }
}
```

**Respuesta exitosa (200 OK):**

```json
{
  "status": "ok"
}
```

> **Nota:** El token JWT **no** se incluye en el cuerpo de la respuesta; se almacena únicamente en la cookie HTTP-only.

**Errores comunes:**

* `401 Unauthorized`: credenciales incorrectas.
* `400 Bad Request`: formato de datos inválido.

---

#### **DELETE** `/users/sign_out` — Cierre de sesión

**Descripción:** Cierra la sesión del usuario autenticado eliminando la cookie HTTP-only.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "logged_out"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.

---

#### **PATCH/PUT** `/users` — Actualizar perfil

**Descripción:** Modifica los datos del usuario autenticado.

**Cuerpo de la solicitud (JSON):**

```json
{
  "user": {
    "first_name": "Juan Carlos",
    "last_name": "Pérez",
    "handle": "@juancp",
    "country_id": 2
  }
}
```

**Respuesta exitosa (200 OK):**

```json
{
  "id": 12,
  "first_name": "Juan Carlos",
  "last_name": "Pérez",
  "handle": "@juancp",
  "email": "juan@example.com",
  "country_id": 2,
  "updated_at": "2025-08-11T15:10:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **DELETE** `/users` — Eliminar cuenta

**Descripción:** Elimina la cuenta del usuario autenticado.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "account_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.

### 4.2 Países (`/countries`)

#### **GET** `/api/v1/countries` — Listar países

**Descripción:** Devuelve la lista completa de países registrados en el sistema.

**Respuesta exitosa (200 OK):**

```json
[
  {
    "id": 1,
    "name": "Chile"
  },
  {
    "id": 2,
    "name": "Argentina"
  },
  {
    "id": 3,
    "name": "Perú"
  }
]
```

**Errores comunes:**

* `500 Internal Server Error`: error inesperado en el servidor.

---

#### **GET** `/api/v1/countries/:id` — Detalle de un país

**Descripción:** Devuelve la información de un país específico identificado por su ID.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 1,
  "name": "Chile"
}
```

**Errores comunes:**

* `404 Not Found`: país no encontrado.
* `400 Bad Request`: ID con formato inválido.

### 4.3 Viajes (`/trips`)

#### **GET** `/api/v1/trips` — Listar viajes del usuario autenticado

**Descripción:** Devuelve todos los viajes creados por el usuario autenticado.

**Respuesta exitosa (200 OK):**

```json
[
  {
    "id": 1,
    "title": "Viaje a la Patagonia",
    "description": "Recorrido por el sur de Chile",
    "starts_on": "2025-12-15",
    "ends_on": "2025-12-30",
    "created_at": "2025-08-11T14:40:00Z",
    "updated_at": "2025-08-11T14:40:00Z"
  },
  {
    "id": 2,
    "title": "Europa 2026",
    "description": "Visita a varias ciudades europeas",
    "starts_on": "2026-05-10",
    "ends_on": "2026-06-15",
    "created_at": "2025-08-11T14:45:00Z",
    "updated_at": "2025-08-11T14:45:00Z"
  }
]
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.

---

#### **POST** `/api/v1/trips` — Crear viaje

**Descripción:** Crea un nuevo viaje asociado al usuario autenticado.

**Cuerpo de la solicitud (JSON):**

```json
{
  "trip": {
    "title": "Viaje al norte",
    "description": "Explorando el desierto de Atacama",
    "starts_on": "2025-09-01",
    "ends_on": "2025-09-10"
  }
}
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 3,
  "title": "Viaje al norte",
  "description": "Explorando el desierto de Atacama",
  "starts_on": "2025-09-01",
  "ends_on": "2025-09-10",
  "created_at": "2025-08-11T15:00:00Z",
  "updated_at": "2025-08-11T15:00:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **GET** `/api/v1/trips/:id` — Ver detalle de un viaje

**Descripción:** Devuelve los datos de un viaje específico del usuario autenticado.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 1,
  "title": "Viaje a la Patagonia",
  "description": "Recorrido por el sur de Chile",
  "starts_on": "2025-12-15",
  "ends_on": "2025-12-30",
  "created_at": "2025-08-11T14:40:00Z",
  "updated_at": "2025-08-11T14:40:00Z",
  "trip_locations": [],
  "travel_buddies": []
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje no encontrado o no pertenece al usuario.

---

#### **PUT/PATCH** `/api/v1/trips/:id` — Editar viaje

**Descripción:** Actualiza la información de un viaje existente del usuario autenticado.

**Cuerpo de la solicitud (JSON):**

```json
{
  "trip": {
    "title": "Viaje a la Patagonia - actualizado",
    "description": "Nuevo itinerario por el sur de Chile"
  }
}
```

**Respuesta exitosa (200 OK):**

```json
{
  "id": 1,
  "title": "Viaje a la Patagonia - actualizado",
  "description": "Nuevo itinerario por el sur de Chile",
  "starts_on": "2025-12-15",
  "ends_on": "2025-12-30",
  "created_at": "2025-08-11T14:40:00Z",
  "updated_at": "2025-08-11T15:05:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje no encontrado o no pertenece al usuario.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **DELETE** `/api/v1/trips/:id` — Eliminar viaje

**Descripción:** Elimina un viaje del usuario autenticado.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "trip_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje no encontrado o no pertenece al usuario.

### 4.4 Ubicaciones (`/locations`)

#### **GET** `/api/v1/locations` — Buscar ubicaciones

**Descripción:** Devuelve una lista de ubicaciones registradas en el sistema. Puede incluir parámetros de búsqueda por nombre o país.

**Parámetros de consulta opcionales:**

* `q`: término de búsqueda por nombre.
* `country_id`: filtrar por ID de país.

**Ejemplo:**

```
GET /api/v1/locations?q=Santiago&country_id=1
```

**Respuesta exitosa (200 OK):**

```json
[
  {
    "id": 5,
    "name": "Santiago",
    "country": {
      "id": 1,
      "name": "Chile"
    }
  },
  {
    "id": 6,
    "name": "Santiago del Estero",
    "country": {
      "id": 2,
      "name": "Argentina"
    }
  }
]
```

**Errores comunes:**

* `500 Internal Server Error`: error inesperado en el servidor.

---

#### **POST** `/api/v1/trips/:trip_id/locations` — Agregar ubicación a viaje

**Descripción:** Agrega una ubicación a un viaje existente del usuario autenticado. Crea un registro en la tabla `trip_locations`.

**Cuerpo de la solicitud (JSON):**

```json
{
  "location": {
    "location_id": 5,
    "position": 1,
    "visited_on": "2025-12-16"
  }
}
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 1,
  "trip_id": 3,
  "location_id": 5,
  "position": 1,
  "visited_on": "2025-12-16",
  "created_at": "2025-08-11T15:20:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje o ubicación no encontrados.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **GET** `/api/v1/locations/:id` — Detalle de ubicación

**Descripción:** Devuelve los datos de una ubicación específica, incluyendo su país.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 5,
  "name": "Santiago",
  "country": {
    "id": 1,
    "name": "Chile"
  }
}
```

**Errores comunes:**

* `404 Not Found`: ubicación no encontrada.
* `400 Bad Request`: ID con formato inválido.

### 4.5 Publicaciones (`/posts`)

#### **GET** `/api/v1/trips/:trip_id/posts` — Listar publicaciones de un viaje

**Descripción:** Devuelve todas las publicaciones asociadas a un viaje específico.

**Respuesta exitosa (200 OK):**

```json
[
  {
    "id": 10,
    "trip_id": 3,
    "location_id": 5,
    "content": "Día increíble en el desierto",
    "created_at": "2025-08-11T15:30:00Z",
    "updated_at": "2025-08-11T15:30:00Z"
  },
  {
    "id": 11,
    "trip_id": 3,
    "location_id": 6,
    "content": "Amanecer espectacular en la montaña",
    "created_at": "2025-08-12T07:15:00Z",
    "updated_at": "2025-08-12T07:15:00Z"
  }
]
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje no encontrado o no pertenece al usuario.

---

#### **POST** `/api/v1/trips/:trip_id/posts` — Crear publicación

**Descripción:** Crea una nueva publicación en un viaje existente del usuario autenticado.

**Cuerpo de la solicitud (JSON):**

```json
{
  "post": {
    "location_id": 5,
    "content": "Día increíble en el desierto",
    "pictures": [
      {"file": "<archivo_imagen>"}
    ],
    "videos": [
      {"file": "<archivo_video>"}
    ],
    "audios": [
      {"file": "<archivo_audio>"}
    ]
  }
}
```

> **Nota:** Los archivos multimedia se envían como `multipart/form-data` usando ActiveStorage.

**Respuesta exitosa (201 Created):**

```json
{
  "id": 12,
  "trip_id": 3,
  "location_id": 5,
  "content": "Día increíble en el desierto",
  "created_at": "2025-08-11T15:35:00Z",
  "updated_at": "2025-08-11T15:35:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje o ubicación no encontrados.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **GET** `/api/v1/posts/:id` — Detalle de una publicación

**Descripción:** Devuelve la información de una publicación específica.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 10,
  "trip_id": 3,
  "location_id": 5,
  "content": "Día increíble en el desierto",
  "pictures": [],
  "videos": [],
  "audios": [],
  "created_at": "2025-08-11T15:30:00Z",
  "updated_at": "2025-08-11T15:30:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: publicación no encontrada.

---

#### **DELETE** `/api/v1/posts/:id` — Eliminar publicación

**Descripción:** Elimina una publicación existente del usuario autenticado.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "post_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: publicación no encontrada o no pertenece al usuario.

### 4.6 Imágenes (`/pictures`)

#### **POST** `/api/v1/posts/:post_id/pictures` — Subir imagen

**Descripción:** Sube una nueva imagen y la asocia a una publicación existente.

**Cuerpo de la solicitud:**

* Debe enviarse como `multipart/form-data`.
* El campo del archivo debe llamarse `file`.

**Ejemplo con `curl`:**

```bash
curl -X POST \
  -b cookies.txt \
  -F "file=@foto.jpg" \
  http://localhost:3001/api/v1/posts/12/pictures
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 25,
  "post_id": 12,
  "url": "http://localhost:3001/rails/active_storage/blobs/.../foto.jpg",
  "created_at": "2025-08-11T15:50:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: publicación no encontrada.
* `422 Unprocessable Entity`: archivo inválido.

---

#### **GET** `/api/v1/pictures/:id` — Ver imagen

**Descripción:** Devuelve los metadatos de una imagen y su URL pública o protegida.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 25,
  "post_id": 12,
  "url": "http://localhost:3001/rails/active_storage/blobs/.../foto.jpg",
  "created_at": "2025-08-11T15:50:00Z"
}
```

> **Nota:** El acceso directo a la imagen se realiza mediante la URL proporcionada, gestionada por ActiveStorage.

**Errores comunes:**

* `404 Not Found`: imagen no encontrada.

---

#### **DELETE** `/api/v1/pictures/:id` — Eliminar imagen

**Descripción:** Elimina una imagen asociada a una publicación.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "picture_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: imagen no encontrada o no pertenece a una publicación del usuario.

### 4.7 Videos (`/videos`)

#### **POST** `/api/v1/posts/:post_id/videos` — Subir video

**Descripción:** Sube un nuevo video y lo asocia a una publicación existente.

**Cuerpo de la solicitud:**

* Debe enviarse como `multipart/form-data`.
* El campo del archivo debe llamarse `file`.

**Ejemplo con `curl`:**

```bash
curl -X POST \
  -b cookies.txt \
  -F "file=@video.mp4" \
  http://localhost:3001/api/v1/posts/12/videos
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 8,
  "post_id": 12,
  "url": "http://localhost:3001/rails/active_storage/blobs/.../video.mp4",
  "created_at": "2025-08-11T16:10:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: publicación no encontrada.
* `422 Unprocessable Entity`: archivo inválido.

---

#### **GET** `/api/v1/videos/:id` — Ver video

**Descripción:** Devuelve los metadatos de un video y su URL pública o protegida.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 8,
  "post_id": 12,
  "url": "http://localhost:3001/rails/active_storage/blobs/.../video.mp4",
  "created_at": "2025-08-11T16:10:00Z"
}
```

> **Nota:** El acceso directo al video se realiza mediante la URL proporcionada, gestionada por ActiveStorage.

**Errores comunes:**

* `404 Not Found`: video no encontrado.

---

#### **DELETE** `/api/v1/videos/:id` — Eliminar video

**Descripción:** Elimina un video asociado a una publicación.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "video_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: video no encontrado o no pertenece a una publicación del usuario.

### 4.8 Audios (`/audios`)

#### **POST** `/api/v1/posts/:post_id/audios` — Subir audio

**Descripción:** Sube un nuevo archivo de audio y lo asocia a una publicación existente.

**Cuerpo de la solicitud:**

* Debe enviarse como `multipart/form-data`.
* El campo del archivo debe llamarse `file`.

**Ejemplo con `curl`:**

```bash
curl -X POST \
  -b cookies.txt \
  -F "file=@audio.mp3" \
  http://localhost:3001/api/v1/posts/12/audios
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 4,
  "post_id": 12,
  "url": "http://localhost:3001/rails/active_storage/blobs/.../audio.mp3",
  "created_at": "2025-08-11T16:20:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: publicación no encontrada.
* `422 Unprocessable Entity`: archivo inválido.

---

#### **GET** `/api/v1/audios/:id` — Ver audio

**Descripción:** Devuelve los metadatos de un archivo de audio y su URL pública o protegida.

**Respuesta exitosa (200 OK):**

```json
{
  "id": 4,
  "post_id": 12,
  "url": "http://localhost:3001/rails/active_storage/blobs/.../audio.mp3",
  "created_at": "2025-08-11T16:20:00Z"
}
```

> **Nota:** El acceso directo al audio se realiza mediante la URL proporcionada, gestionada por ActiveStorage.

**Errores comunes:**

* `404 Not Found`: audio no encontrado.

---

#### **DELETE** `/api/v1/audios/:id` — Eliminar audio

**Descripción:** Elimina un archivo de audio asociado a una publicación.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "audio_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: audio no encontrado o no pertenece a una publicación del usuario.

### 4.9 Etiquetas (`/tags`)

#### **POST** `/api/v1/pictures/:picture_id/tags` — Crear etiqueta

**Descripción:** Crea una nueva etiqueta para un usuario en una imagen específica.

**Cuerpo de la solicitud (JSON):**

```json
{
  "tag": {
    "user_id": 7
  }
}
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 15,
  "picture_id": 25,
  "user_id": 7,
  "created_at": "2025-08-11T16:30:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: imagen o usuario no encontrados.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **DELETE** `/api/v1/pictures/:picture_id/tags/:id` — Eliminar etiqueta

**Descripción:** Elimina una etiqueta específica de una imagen.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "tag_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: etiqueta no encontrada o no pertenece a una imagen del usuario.

### 4.10 Compañeros de viaje (`/travel_buddies`)

#### **POST** `/api/v1/trips/:trip_id/travel_buddies` — Agregar compañero de viaje

**Descripción:** Agrega un usuario como compañero de viaje en un viaje específico.

**Cuerpo de la solicitud (JSON):**

```json
{
  "travel_buddy": {
    "user_id": 8
  }
}
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 5,
  "trip_id": 3,
  "user_id": 8,
  "created_at": "2025-08-11T16:40:00Z"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: viaje o usuario no encontrados.
* `422 Unprocessable Entity`: datos inválidos.

---

#### **DELETE** `/api/v1/trips/:trip_id/travel_buddies/:id` — Eliminar compañero

**Descripción:** Elimina un compañero de viaje de un viaje específico.

**Respuesta exitosa (200 OK):**

```json
{
  "status": "travel_buddy_deleted"
}
```

**Errores comunes:**

* `401 Unauthorized`: sin cookie JWT válida.
* `404 Not Found`: compañero no encontrado o no pertenece al viaje del usuario.

## 5. Ejemplos de uso con Postman

### Configuración de entorno

Para probar la API con **Postman**:

1. Crear un nuevo entorno en Postman llamado, por ejemplo, *API TravelLog*.
2. Configurar las siguientes variables de entorno:

   * `base_url`: `http://localhost:3001/api/v1`
   * `email`: correo del usuario de pruebas.
   * `password`: contraseña del usuario de pruebas.
3. Guardar los cambios.

> **Nota:** Como la autenticación utiliza cookies HTTP-only, Postman debe estar configurado para **guardar cookies** automáticamente. Esto permite que la cookie con el token JWT se incluya en las siguientes solicitudes sin necesidad de añadir manualmente un encabezado `Authorization`.

---

### Variables de entorno

En Postman, las variables de entorno se referencian con `{{variable}}`. Ejemplo de uso en una solicitud:

```
{{base_url}}/trips
```

Esto se traducirá a `http://localhost:3001/api/v1/trips` en tiempo de ejecución.

---

Para agilizar las pruebas:

* Importar la colección pública del curso: [Postman Collection](https://bit.ly/icc4203-202420-project-postman-collection)
* Esta colección incluye ejemplos de:

  * Registro (`POST /users`)
  * Inicio de sesión (`POST /users/sign_in`)
  * Creación y consulta de viajes
  * Gestión de ubicaciones y publicaciones

**Recomendaciones:**

* Ejecutar primero las solicitudes de **registro** o **inicio de sesión** para obtener la cookie de autenticación.
* Mantener las solicitudes en orden lógico para simular un flujo real de uso.
* Usar la pestaña **Cookies** de Postman para verificar que la cookie de sesión (`_your_app_session`) se haya guardado correctamente después de iniciar sesión.

## 6. Manejo de Errores

### Formato de respuesta de error

Todas las respuestas de error de la API siguen el formato JSON:

```json
{
  "error": "Mensaje descriptivo del error"
}
```

En algunos casos, especialmente en errores de validación (`422 Unprocessable Entity`), la respuesta puede incluir un objeto con detalles por campo:

```json
{
  "errors": {
    "title": ["can't be blank"],
    "starts_on": ["is not a valid date"]
  }
}
```

---

### Errores comunes

* **401 Unauthorized**: el usuario no está autenticado o la cookie JWT no es válida o ha expirado.

  ```json
  { "error": "You need to sign in or sign up before continuing." }
  ```

* **403 Forbidden**: el usuario está autenticado pero no tiene permisos para acceder al recurso.

  ```json
  { "error": "You are not authorized to perform this action." }
  ```

* **404 Not Found**: el recurso solicitado no existe o no pertenece al usuario.

  ```json
  { "error": "Resource not found" }
  ```

* **422 Unprocessable Entity**: error de validación de datos.

  ```json
  {
    "errors": {
      "email": ["has already been taken"],
      "password": ["is too short (minimum is 8 characters)"]
    }
  }
  ```

* **500 Internal Server Error**: error inesperado en el servidor.

  ```json
  { "error": "Internal server error" }
  ```

---

### Ejemplos prácticos

1. **Intentar crear un viaje sin título:**

   * Solicitud:

   ```json
   {
     "trip": {
       "description": "Viaje sin título"
     }
   }
   ```

   * Respuesta (`422 Unprocessable Entity`):

   ```json
   {
     "errors": {
       "title": ["can't be blank"]
     }
   }
   ```

2. **Acceder a un viaje que pertenece a otro usuario:**

   * Respuesta (`404 Not Found`):

   ```json
   { "error": "Resource not found" }
   ```

3. **Llamar a un endpoint protegido sin iniciar sesión:**

   * Respuesta (`401 Unauthorized`):

   ```json
   { "error": "You need to sign in or sign up before continuing." }
   ```

## 7. Notas para Desarrolladores

### Uso de ActiveStorage para archivos multimedia

* **ActiveStorage** se utiliza para gestionar la carga y acceso a imágenes, videos y audios.
* Los archivos se asocian a modelos como `Picture`, `Video` y `Audio`.
* El almacenamiento por defecto en desarrollo es en el sistema de archivos local (`storage/`). En producción, puede configurarse un servicio en la nube (Amazon S3, Google Cloud Storage, etc.).
* Las URLs de acceso a archivos son generadas dinámicamente y pueden expirar según la configuración.
* Para pruebas con herramientas como Postman, usar `multipart/form-data` y el campo `file` para enviar los archivos.

---

### Relaciones entre entidades y restricciones

* Un **User** puede tener muchos **Trips**, **Posts**, **Pictures**, **Videos**, **Audios** y **Tags**.
* Un **Trip** pertenece a un **User** y puede tener muchas **Locations** (a través de `TripLocations`) y **TravelBuddies**.
* Una **Location** pertenece a un **Country**.
* Un **Post** pertenece a un **Trip** y a una **Location**.
* Una **Picture**, **Video** o **Audio** pertenece a un **Post**.
* Una **Tag** pertenece a un **Picture** y a un **User**.
* Restricciones comunes:

  * Campos obligatorios validados en los modelos (`presence: true`).
  * Relaciones con `dependent: :destroy` para asegurar borrado en cascada.

---

### Índices y validaciones relevantes

* Índices en campos clave como `email` (único), `handle` (único) y claves foráneas (`user_id`, `trip_id`, etc.).
* Validaciones de formato en campos como `email` y fechas (`starts_on`, `ends_on`).
* Validaciones de unicidad para evitar registros duplicados (ej. `handle`, `country_id` por usuario en ciertas relaciones).
* Validación de tipos de archivo para cargas multimedia según el modelo (imágenes, videos, audios).

---

### Buenas prácticas de consumo de API

* **Autenticación:** Mantener la cookie HTTP-only segura y evitar exponer el token JWT en el cliente.
* **Paginación:** Implementar paginación en listados grandes para mejorar rendimiento.
* **Validaciones en cliente:** Realizar validaciones previas en el frontend antes de enviar datos a la API.
* **Manejo de errores:** Interpretar los códigos HTTP y mostrar mensajes claros al usuario.
* **Optimización de multimedia:** Reducir tamaño de imágenes y videos antes de subirlos para mejorar rendimiento y reducir uso de almacenamiento.
* **Versionado:** Respetar el prefijo `/api/v1` y mantener compatibilidad con versiones futuras.
* **Seguridad:** Usar HTTPS en entornos de producción para proteger la transmisión de datos.

