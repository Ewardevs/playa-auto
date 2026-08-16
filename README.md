# Playa Autos

Aplicación Rails para una playa de autos, con cuatro caras sobre la misma base
de datos:

- **`/admin` — panel de administración.** Inventario con fotografías, marcas y
  modelos, categorías, ofertas, consultas, contenido, configuración y usuarios
  con roles.
- **`/` — web pública institucional.** Catálogo con búsqueda y filtros, ficha de
  vehículo, ofertas, páginas institucionales, formulario de consulta y WhatsApp
  como canal principal de conversión.
- **`/v2` — segunda web pública (Site2).** El mismo alcance funcional que la
  anterior, con una identidad visual propia e independiente.
- **`/v3` — tercera web pública (Site3).** Otra identidad más, construida como
  se construye hoy una aplicación.

`/v2` y `/v3` conviven con `/`; no la reemplazan. Mientras
`config.x.siteN.preview` esté en `true` se sirven con `noindex` y no aparecen en
`sitemap.xml` ni en `robots.txt`.

Las cuatro comparten los modelos de dominio, los query objects y los services.
Lo que está separado es la presentación: controladores, vistas, componentes y
rutas. No hay modelos paralelos, ni una API interna, ni datos duplicados: una
consulta enviada desde cualquiera de las tres webs es la misma fila que el
vendedor trabaja en el panel.

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
│   ├── admin/              # el panel, bajo /admin
│   ├── site/               # la web pública
│   ├── site2/              # la segunda web pública, bajo /v2
│   ├── site3/              # la tercera web pública, bajo /v3
│   └── application_controller.rb
├── components/
│   ├── ui/                 # UI:: — compartido: botones, badges, paginación, campos
│   ├── admin/              # Admin:: — sidebar, tablas, gráficos del panel
│   ├── site/               # Site:: — header, hero, card, galería, filtros, WhatsApp
│   ├── site2/              # Site2:: — mismas piezas, otro lenguaje visual
│   ├── site3/              # Site3:: — y otro más
│   ├── vehicles/           # Vehicles:: — piezas de vehículo del panel
│   └── inquiries/
├── models/
│   ├── concerns/           # Sluggable, Auditable, Activatable
│   ├── seo/                # SEO::Metadata
│   └── …                   # dominio compartido por Admin y Site
├── policies/               # Pundit (solo el panel: la web es de lectura)
├── queries/                # vehicles/{public,public_search,search,featured,related,on_offer}
├── services/               # inquiries/create, vehicles/{duplicate,change_status,whatsapp_message}
├── helpers/                # formatting_helper (compartido), admin_helper
└── views/
    ├── admin/
    ├── site/
    ├── site2/
    ├── site3/
    ├── layouts/            # admin, site, site2, site3, auth, application
    └── users/              # pantallas de Devise
```

Criterio de separación:

- **Models, services y queries son compartidos.** No existen `SiteVehicle` ni
  `Admin::VehicleService`. El dominio es uno solo.
- **Controllers, views y componentes se separan por contexto.** Lo del panel en
  `Admin::`, lo público en `Site::`, `Site2::` y `Site3::`, lo genérico y
  reutilizable en `UI::`.
- **Un componente se comparte cuando puede.** `UI::PaginationComponent` es el
  mismo en los cuatro lados: la lógica de la ventana de páginas no se duplica,
  solo cambia la piel (`theme: :admin`, `:site`, `:site2` o `:site3`).
- **Las tres webs públicas no se conocen entre sí.** Ninguna llama a nada de las
  otras. Lo que comparten —modelos, queries, services, `UI::`, `SEO::Metadata`,
  `FormattingHelper`— lo comparten con el panel también.
- **Service objects solo cuando aportan.** Un CRUD simple se resuelve en el
  controlador; los que existen coordinan varios pasos.
- **Query objects para todo filtro.** `Vehicles::PublicSearch` traduce el query
  string público a una relación, siempre partiendo de `Vehicles::Public`.

## Decisiones que conviene conocer

**Qué llega a la web pública.** `Vehicles::Public` es la única puerta entre el
inventario y el sitio, y lo que devuelve lo decide el negocio, nunca la URL:

- Archivados y ocultos no salen del panel jamás.
- Los vendidos se muestran o no según `Setting#show_sold_vehicles` (Configuración
  → General). Cuando se muestran, van etiquetados como vendidos.
- Los reservados sí aparecen, marcados, con el aviso correspondiente en la ficha.
- Un vehículo no público responde **404**, no una página que revele que existe.
- `?estado=…` solo puede *estrechar* lo que ya es público. Ningún parámetro
  amplía el alcance.

**Rutas públicas.**

```text
/                        home
/vehiculos               catálogo con búsqueda, filtros, orden y paginación
/vehiculos/:slug         ficha (toyota-hilux-2024)
/ofertas                 promociones vigentes
/nosotros
/preguntas-frecuentes
/contacto
/sitemap.xml
/robots.txt
```

**SEO.** Cada página define título, descripción y canonical a través de
`SEO::Metadata`. El catálogo filtrado o paginado apunta su canonical a
`/vehiculos` y va `noindex`, para no competir consigo mismo. Los vehículos
generan Open Graph con su foto principal y JSON-LD `Car` + `Offer`; la home
publica `AutoDealer`, las FAQ `FAQPage` y todas las páginas `BreadcrumbList`.
El sitemap se arma desde el mismo alcance público, así que nunca puede
anunciar un vehículo oculto.

**Anti-spam sin molestar al comprador.** El formulario lleva un honeypot y la
marca de tiempo en que se abrió; `Inquiries::Create` descarta lo que llega
instantáneamente o con el campo trampa lleno, y de-duplica por teléfono y
vehículo dentro de diez minutos para que un doble toque no genere dos consultas.
El controlador además limita a 8 envíos cada 5 minutos por IP. No hay CAPTCHA:
se agrega si aparece un problema real.

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

Son cuatro identidades distintas a propósito. El panel y la web resuelven
trabajos distintos; las tres webs públicas existen para poder compararlas.

### La web pública — *showroom*

Papel cálido para el contenido, bandas grafito para el hero y el pie, y un verde
profundo de herencia automotriz como único color de marca. La fotografía manda:
la interfaz es una moldura fina alrededor de las fotos.

- Tipografías: Familjen Grotesk (títulos), Public Sans (texto), IBM Plex Mono
  (precios y datos).
- La firma visual es la **chapa de datos**: año · km · caja · combustible en
  monoespaciada separados por filetes, idéntica en las cards, en la ficha y en
  los resultados, para que el comprador compare siempre en el mismo lugar.
- El buscador va encastrado en el borde inferior del hero: lo primero que se
  puede hacer al entrar es buscar un auto.
- Header transparente sobre el hero que se vuelve sólido al scrollear; en las
  páginas internas es sólido desde el primer pintado.
- Mobile-first de verdad: los filtros son barra lateral en escritorio y cajón
  inferior en el teléfono, con el mismo formulario (no se esconden elementos).

### Site2 (`/v2`) — *vitrina nocturna*

El mismo salón, de noche: fondo casi negro, la fotografía sangrando hasta el
borde y un solo color —naranja de señalización— reservado para donde hay que
actuar o donde hay una oferta. No comparte **ninguna** decisión visual con la
web anterior.

- Tipografías: Bricolage Grotesque (títulos y cifras) e Inter Tight (interfaz).
  Sin monoespaciada.
- La firma visual es el **dato**: cifra grande en display con una etiqueta
  diminuta en versalitas encima. Se repite en las cards, en la ficha y en las
  estadísticas, y es la unidad con la que se lee todo el sitio.
- Las cards son **afiches verticales** (4∶5): la foto ocupa la pieza entera y
  los datos van encima, sobre un degradado. No hay panel blanco debajo.
- Las secciones están **numeradas** (01, 02, …) y colgadas de un filete que
  cruza el ancho.
- Los filtros son una franja fija con el texto libre y el orden, y un panel a
  ancho completo que se despliega **en el flujo** y empuja los resultados hacia
  abajo — el mismo en el teléfono y en el escritorio. Es un `<details>` nativo:
  se abre sin JavaScript. Los filtros aplicados aparecen como fichas que se
  quitan de a una, cada una un enlace normal.
- La galería de la ficha es un **carril horizontal con anclaje de scroll** y un
  indicador segmentado, no una foto principal con miniaturas.
- El encabezado nunca cambia de color: se encoge al bajar y lleva un hilo de
  progreso de lectura.
- Tokens y clases con prefijo `s2-`, para que nada de acá pueda alcanzar al
  panel ni a la web anterior.

### Site3 (`/v3`) — *producto*

Ni el showroom de día del primero ni la vitrina nocturna del segundo: está
construido como se construye hoy una aplicación. Lienzo claro y frío,
superficies blancas que flotan sobre él, radios grandes, profundidad por sombra
en capas en vez de por líneas, y un índigo eléctrico como único color de acción.
El verde menta queda reservado para una sola cosa: el ahorro.

- Tipografías: Instrument Serif para los titulares grandes e Instrument Sans
  para la interfaz. Es el único de los tres que mezcla serif con sans.
- **Sin versalitas espaciadas.** Los otros dos etiquetan todo en mayúsculas; acá
  las etiquetas van en caja baja, dentro de píldoras.
- La barra superior es una **isla flotante**: una píldora centrada que no toca
  los bordes, se esconde al bajar y vuelve al subir.
- La portada y la página institucional son **mosaicos**: piezas de distinto
  tamaño, cada una en su propia superficie.
- En las cards la fotografía va **encastrada** —dentro de la pieza, con su
  propio radio y un margen— y los datos son píldoras, no una chapa
  monoespaciada ni bloques de cifra grande.
- Los filtros son **una píldora por filtro**, cada una con su desplegable
  propio; la píldora muestra el valor elegido y le crece una × para quitarlo de
  un clic. Todo con `<details>` nativo, sin JavaScript.
- La galería de la ficha es un **mosaico**: una foto grande y hasta cuatro
  chicas, todas visibles a la vez. No hay nada que navegar.
- El precio de una oferta se comunica en plata ("Ahorrás $ X"), no en
  porcentaje: un porcentaje obliga a hacer una cuenta.
- Tokens y clases con prefijo `s3-`.

### El panel — *tablero de instrumentos*

Grafito, líneas de
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

## Preparado, pero no implementado

La arquitectura no bloquea lo que sigue, y nada de esto exige rediseñar:

- **Analítica.** `Site::AnalyticsComponent` ya inyecta Google Analytics, Tag
  Manager y Meta Pixel; solo hay que cargar el identificador en Configuración.
  Se activan únicamente en producción.
- **Métricas de conversión.** Los vehículos ya cuentan visitas
  (`views_count`), consultas (`inquiries_count`) y clics de WhatsApp
  (`whatsapp_clicks_count`). El panel ya reporta las dos primeras.
- **Más secciones institucionales.** Los diferenciales son un modelo con su
  propio CRUD; sumar testimonios o sucursales sigue el mismo patrón.
- **Financiación, test drive, comparador, favoritos, blog.** Ninguna decisión
  tomada hasta ahora los impide.
# playa-auto
