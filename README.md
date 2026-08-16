# Playa Autos — panel administrativo

Panel de administración para una playa de autos: inventario de vehículos con
fotografías, marcas y modelos, categorías, ofertas, consultas de clientes,
contenido del sitio, configuración de la empresa y usuarios con roles.

El sitio público todavía no está desarrollado. La aplicación está organizada
para que se agregue después bajo el namespace `Site::` sin mover nada de lo que
ya existe.

## Stack

| Pieza | Versión / elección |
| --- | --- |
| Ruby | 3.4.10 |
| Rails | 8.1.3 |
| Base de datos | PostgreSQL 16 |
| CSS | Tailwind CSS 4 (`tailwindcss-rails`, sin Node) |
| JavaScript | Importmap + Hotwire (Turbo y Stimulus) |
| Componentes | ViewComponent |
| Autenticación | Devise |
| Autorización | Pundit |
| Imágenes | Active Storage + ImageMagick |
| Paginación | Pagy |
| Archivado | Discard |

No hay Node, Vite ni Webpack: Tailwind se compila con el binario que trae
`tailwindcss-rails` y el JavaScript se sirve con importmap.

## Puesta en marcha

### 1. Requisitos

- Ruby 3.4.10 (`.ruby-version` ya está en el repositorio)
- PostgreSQL 16 o superior
- ImageMagick (`magick`) para las variantes de imagen

En Arch Linux:

```bash
sudo pacman -S postgresql imagemagick
```

### 2. Base de datos

La aplicación se conecta por TCP y toma los datos de conexión de estas
variables, con valores por defecto pensados para desarrollo local:

| Variable | Default |
| --- | --- |
| `DATABASE_HOST` | `127.0.0.1` |
| `DATABASE_PORT` | `5432` |
| `DATABASE_USER` | `ewardevs` |
| `DATABASE_PASSWORD` | `ewardevs` |

Si usás PostgreSQL en Docker:

```bash
docker run -d --name playa-postgres \
  -e POSTGRES_USER=ewardevs \
  -e POSTGRES_PASSWORD=ewardevs \
  -p 5432:5432 \
  postgres:16-alpine
```

Con otras credenciales, exportá las variables antes de los comandos siguientes.

### 3. Instalación

```bash
bundle install
bin/rails db:prepare   # crea, migra y carga el esquema
bin/rails db:seed      # datos de ejemplo
bin/dev                # servidor + compilación de Tailwind en watch
```

El panel queda en <http://localhost:3000/admin>.

> El esquema se versiona en `db/structure.sql` (no `schema.rb`) porque usa una
> secuencia de PostgreSQL para los códigos internos de vehículo y un índice
> único parcial para la foto principal, cosas que `schema.rb` no sabe expresar.

### 4. Usuarios de prueba

Los crea `db/seeds.rb`. Existen **solo en el seed**: ningún punto del código de
la aplicación los da por sentado.

| Rol | Email | Contraseña |
| --- | --- | --- |
| Super Admin | `admin@playaguarani.com.py` | `Password1!` |
| Administrador | `gerencia@playaguarani.com.py` | `Password1!` |
| Vendedor | `ventas@playaguarani.com.py` | `Password1!` |
| Vendedora | `rocio@playaguarani.com.py` | `Password1!` |
| Editora | `contenido@playaguarani.com.py` | `Password1!` |

Podés cambiar la contraseña con `SEED_PASSWORD=... bin/rails db:seed`.

El seed es idempotente: correrlo dos veces no duplica nada.

## Roles y permisos

Los permisos se definen en `app/policies/` y se aplican en el backend. El menú
lateral consulta las mismas policies, así que nadie ve una sección que no puede
abrir.

| | Super Admin | Administrador | Vendedor | Editor |
| --- | :-: | :-: | :-: | :-: |
| Ver vehículos | ✓ | ✓ | ✓ | — |
| Crear / editar vehículos | ✓ | ✓ | ✓ | — |
| Cambiar estado | ✓ | ✓ | ✓ | — |
| Destacar vehículo | ✓ | ✓ | — | — |
| Archivar / eliminar vehículos | ✓ | ✓ | — | — |
| Marcas, modelos, categorías | ✓ | ✓ | solo ver | — |
| Ofertas | ✓ | ✓ | solo ver | — |
| Consultas | ✓ | ✓ | ✓ | — |
| Contenido y FAQ | ✓ | ✓ | — | ✓ |
| Auditoría | ✓ | ✓ | — | — |
| Usuarios | ✓ | — | — | — |
| Configuración | ✓ | — | — | — |

Dos reglas se aplican siempre, sin importar el rol:

- Nadie puede modificar sus propios permisos. `ProfilePolicy` no incluye `role`
  ni `active` entre los atributos permitidos, así que enviarlos en el formulario
  no tiene efecto.
- No se puede degradar ni desactivar al último Super Admin: lo impide una
  validación en `User`.

## Estructura

```text
app/
├── controllers/
│   ├── admin/              # todo el panel, bajo /admin
│   └── application_controller.rb
├── components/
│   ├── ui/                 # UI:: — botones, badges, tablas, modales, campos…
│   ├── admin/              # Admin:: — sidebar, header, breadcrumbs, gráficos
│   ├── vehicles/           # Vehicles:: — galería, miniatura, badge de estado
│   └── inquiries/
├── models/
│   ├── concerns/           # Sluggable, Auditable, Activatable
│   └── …                   # modelos de dominio, compartidos con el futuro Site
├── policies/               # Pundit
├── queries/                # objetos de consulta (búsqueda y filtros)
├── services/               # operaciones de negocio con más de un paso
├── helpers/
└── views/
    ├── admin/
    ├── layouts/            # admin, auth, application
    └── users/              # pantallas de Devise
```

Criterio de separación:

- **Models, services y queries son compartidos.** No se duplican entre Admin y
  Site.
- **Controllers, views y componentes se separan por contexto.** Lo que es solo
  del panel vive bajo `Admin::`; lo genérico y reutilizable, en `UI::`.
- **Service objects solo cuando aportan.** Un CRUD simple se resuelve en el
  controlador; `Vehicles::Duplicate`, `Vehicles::ChangeStatus`,
  `Vehicles::ReorderImages` e `Inquiries::UpdateStatus` existen porque cada uno
  coordina varios pasos.
- **Query objects para filtros.** `Vehicles::Search` e `Inquiries::Filter`
  traducen el query string a una relación; están escritos pensando en que el
  catálogo público los reutilice.

## Decisiones que conviene conocer

**Códigos internos.** `V-00042` sale de una secuencia de PostgreSQL
(`vehicle_codes`), no de un `MAX(id) + 1`. Dos usuarios creando vehículos al
mismo tiempo nunca chocan contra el índice único.

**Fotografías.** Se modelan con `VehicleImage` en vez de un `has_many_attached`
suelto, porque el orden y la foto principal tienen que ser columnas
consultables. Un índice único parcial garantiza a nivel de base de datos que
haya como máximo una principal por vehículo. Las variantes (`thumb`, `card`,
`large`) ya están declaradas.

**Ofertas: una sola fuente de verdad.** El precio promocional se carga *solo*
en el módulo de Ofertas, y ahí se pide únicamente el precio promocional y las
fechas:

- `offers.previous_price` lo copia el modelo del precio de lista del vehículo al
  guardar. No está en el formulario ni en los atributos permitidos, así que no se
  puede publicar un "antes" que la playa nunca pidió, ni siquiera con un request
  armado a mano.
- `vehicles.on_offer` es **derivado**: lo mantiene `Offer#sync_vehicle_offer_flag`
  según si la oferta está vigente. No está en el formulario del vehículo ni en
  `VehiclePolicy#permitted_attributes`. Existe como columna solo para que el
  catálogo público pueda filtrar por un índice.
- El vehículo de una oferta se elige una vez: `vehicle_id` solo se acepta al
  crear. Moverla cambiaría el precio contra el que se publicó.

La ficha del vehículo muestra el estado de la oferta en un panel de solo lectura
con acceso directo al módulo. `Vehicle#current_price` devuelve el promocional
cuando hay una oferta vigente, y el de lista cuando no.

**Archivado.** Los vehículos usan `discard`: archivar no borra. Los listados
parten de `.kept` y el archivado se pide explícitamente con `?archived=1`. No se
usa `default_scope`, para que ninguna consulta filtre por accidente.

**Auditoría.** El concern `Auditable` registra quién cambió qué y cuándo, con el
diff de los atributos declarados. Nunca rompe la operación auditada: si el
registro falla, se loguea y la operación sigue. El nombre del usuario se guarda
desnormalizado para que el historial siga siendo legible si se elimina la
cuenta.

**Configuración.** No hay teléfonos, direcciones ni nombres de empresa
hardcodeados. Todo sale de `Setting.current`, editable desde
Configuración y listo para que lo consuma el sitio público.

**SEO.** Vehículos, marcas y categorías ya tienen `slug`, `meta_title` y
`meta_description`. Los slugs se generan una vez y se mantienen estables aunque
se renombre el registro, así las URLs públicas no se rompen.

## Diseño

La interfaz sigue una dirección de *tablero de instrumentos*: grafito, líneas de
un pixel y números en monoespaciada, con ámbar como único color que "se
enciende". Los estados usan los colores convencionales de un tablero real —
verde disponible, ámbar reservado, azul vendido, gris oculto — dibujados como
testigos luminosos.

- Tipografías: Archivo (títulos y cifras), IBM Plex Sans (interfaz), IBM Plex
  Mono (códigos, precios, kilometraje).
- Modo claro y oscuro, con la preferencia guardada por dispositivo.
- Responsive: el sidebar se colapsa a una barra de iconos en escritorio y se
  convierte en cajón lateral en pantallas chicas.
- Los gráficos son SVG generados en el servidor. No hay librería de charts.

## Salud y observabilidad

- `GET /up` responde 200 si la aplicación levanta.
- Las operaciones importantes quedan en la auditoría, consultable desde el panel.
- Los intentos de acceso denegados se registran con `[authz]` en el log.
- No se loguean contraseñas ni tokens.

Para agregar Sentry u otro servicio no hace falta tocar la arquitectura: alcanza
con el initializer del proveedor.

## Comandos útiles

```bash
bin/dev                      # servidor de desarrollo (Rails + Tailwind watch)
bin/rails db:seed            # recarga datos de ejemplo (idempotente)
bin/rails console
bin/rubocop                  # estilo (rubocop-rails-omakase)
bin/brakeman                 # análisis de seguridad estático
bin/rails zeitwerk:check     # verifica el autoloading
bin/rails tailwindcss:build  # compila el CSS una vez
```

## Qué falta

El sitio público (`Site::`). Los modelos, los slugs, los campos SEO y los query
objects ya están preparados para eso: falta escribir controladores, vistas y
componentes bajo ese namespace.
