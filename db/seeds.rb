# Development seed data.
#
# Idempotent: safe to run repeatedly. Creates enough volume that the tables,
# filters, charts and dashboard all have something real to show.
#
#   bin/rails db:seed
#
# Credentials for every generated account are printed at the end. They exist
# only here — nothing in the application code assumes them.

DEV_PASSWORD = ENV.fetch("SEED_PASSWORD", "Password1!")

def say(message) = puts("  #{message}")

puts "\n== Configuración =="

setting = Setting.current
setting.update!(
  company_name: "Playa Guaraní",
  tagline: "Autos usados seleccionados en Asunción",
  phone: "021 664 200",
  whatsapp: "595981447120",
  email: "ventas@playaguarani.com.py",
  address: "Avda. Eusebio Ayala 2350, Asunción",
  opening_hours: "Lunes a viernes de 8:00 a 18:00\nSábados de 8:00 a 13:00",
  google_maps_url: "https://maps.google.com/?q=-25.3006,-57.5759",
  instagram_url: "https://instagram.com/playaguarani",
  facebook_url: "https://facebook.com/playaguarani",
  currency: "USD",
  show_sold_vehicles: false
)
say "#{setting.company_name} lista"

SiteContent.current.update!(
  hero_title: "Tu próximo auto te está esperando",
  hero_subtitle: "Más de 100 vehículos revisados y listos para entregar",
  hero_text: "Trabajamos con unidades verificadas mecánicamente, documentación al día y financiación " \
             "en el acto. Vení a verlos o escribinos por WhatsApp.",
  hero_button_label: "Ver catálogo",
  hero_button_url: "/vehiculos",
  about_title: "Veinte años vendiendo confianza",
  about_description: "Playa Guaraní nació en 2005 como un pequeño local sobre Eusebio Ayala. " \
                     "Hoy somos uno de los referentes de vehículos usados del país, con un " \
                     "taller propio donde cada unidad pasa por una revisión de 60 puntos antes " \
                     "de salir a la venta."
)
say "contenido del sitio listo"

puts "\n== Usuarios =="

users = {
  super_admin: { name: "Edgar Duarte",   email: "admin@playaguarani.com.py",   role: :super_admin },
  admin:       { name: "Lucía Benítez",  email: "gerencia@playaguarani.com.py", role: :admin },
  seller:      { name: "Mario Ojeda",    email: "ventas@playaguarani.com.py",  role: :seller },
  seller_two:  { name: "Rocío Cabrera",  email: "rocio@playaguarani.com.py",   role: :seller },
  editor:      { name: "Nadia Fretes",   email: "contenido@playaguarani.com.py", role: :editor },
  demo_super_admin: { name: "Admin Demo", email: "admin@admin.com", role: :super_admin, password: "Admin123!" }
}.transform_values do |attributes|
  User.find_or_initialize_by(email: attributes[:email]).tap do |user|
    user.assign_attributes(attributes.merge(password: attributes[:password] || DEV_PASSWORD, active: true))
    user.save!
  end
end
say "#{users.size} usuarios"

# Everything below is attributed to the sales lead, so the audit trail is not
# a wall of "Sistema".
Current.user = users[:seller]

puts "\n== Catálogo =="

CATALOG = {
  "Toyota" => %w[Hilux Corolla RAV4 Yaris Land\ Cruiser Etios],
  "Volkswagen" => %w[Amarok Gol Polo T-Cross Virtus],
  "Chevrolet" => %w[S10 Onix Tracker Spin],
  "Ford" => %w[Ranger EcoSport Focus Territory],
  "Hyundai" => %w[Tucson Creta HB20 Santa\ Fe],
  "Nissan" => %w[Frontier Kicks Versa X-Trail],
  "Honda" => %w[CR-V Civic HR-V],
  "Kia" => %w[Sportage Cerato Seltos]
}.freeze

CATEGORIES = [
  [ "Autos", "Sedanes y hatchbacks para el día a día." ],
  [ "SUVs", "Espacio y altura para la ciudad y la ruta." ],
  [ "Camionetas", "Pick-ups de trabajo y doble cabina." ],
  [ "Utilitarios", "Furgones y vehículos de carga." ],
  [ "Motos", "Motocicletas de calle y trabajo." ]
].freeze

categories = CATEGORIES.each_with_index.map do |(name, description), index|
  Category.find_or_initialize_by(name: name).tap do |category|
    category.assign_attributes(description: description, position: index, active: true)
    category.save!
  end
end
say "#{categories.size} categorías"

brands = CATALOG.keys.each_with_index.map do |name, index|
  Brand.find_or_initialize_by(name: name).tap do |brand|
    brand.assign_attributes(position: index, active: true)
    brand.save!
  end
end

models = CATALOG.flat_map do |brand_name, model_names|
  brand = brands.find { |b| b.name == brand_name }

  model_names.map do |model_name|
    VehicleModel.find_or_initialize_by(brand: brand, name: model_name).tap do |model|
      model.active = true
      model.save!
    end
  end
end
say "#{brands.size} marcas, #{models.size} modelos"

puts "\n== Fotografías de ejemplo =="

# Placeholder photos are generated locally with ImageMagick — no network, no
# binary blobs checked into the repo.
PHOTO_PALETTE = %w[
  1f2a37,2f3e52 3a2f2a,55433a 24313a,36505e 2e2a35,463f52
  1e3330,2f504a 33291f,564733 22283a,3a4260 2b1f24,4a373f
].freeze

def build_photo(label, index)
  from, to = PHOTO_PALETTE[index % PHOTO_PALETTE.size].split(",")
  path = Rails.root.join("tmp", "seed_photo_#{index}.jpg")

  return path if path.exist?

  system(
    "magick", "-size", "1200x800",
    "gradient:##{from}-##{to}",
    "-gravity", "center",
    # No explicit -font: font availability varies by machine and a missing
    # family makes ImageMagick fail the whole command.
    "-pointsize", "56", "-fill", "#ffffffcc",
    "-annotate", "+0-30", label,
    "-pointsize", "22", "-fill", "#ffffff66",
    "-annotate", "+0+40", "PLAYA GUARANÍ",
    path.to_s,
    exception: false
  )

  path.exist? ? path : nil
end

photos_available = build_photo("Playa Guaraní", 0).present?
say photos_available ? "generadas con ImageMagick" : "ImageMagick no disponible: se cargan vehículos sin fotos"

puts "\n== Vehículos =="

COLORS = [ "Blanco perlado", "Gris plata", "Negro", "Rojo", "Azul marino", "Beige", "Verde oliva" ].freeze
ENGINES = [ "2.8 TDI", "2.0 TSI", "1.6 16v", "1.8 CVT", "3.0 V6", "1.0 Turbo", "2.4 GDI" ].freeze
EQUIPMENT = [
  "Aire acondicionado automático", "Cámara de retroceso", "Sensores de estacionamiento",
  "Control crucero", "Pantalla táctil con Android Auto", "Llantas de aleación",
  "Faros LED", "Tapizado de cuero", "Airbags laterales", "Control de estabilidad",
  "Tracción 4x4", "Techo solar", "Arranque sin llave", "Butacas eléctricas"
].freeze

STATUS_WEIGHTS = ([ :available ] * 12 + [ :reserved ] * 3 + [ :sold ] * 4 + [ :hidden ] * 1).freeze

random = Random.new(20_260_815)
created_vehicles = []
VEHICLE_TARGET = 70

# Guarded on the total rather than per-record: the generator is seeded, so
# skipping individual rows part-way through would desync the sequence and every
# later lookup would miss, quietly creating duplicates on each run.
if Vehicle.count < VEHICLE_TARGET
  VEHICLE_TARGET.times do |index|
    model  = models[random.rand(models.size)]
    status = STATUS_WEIGHTS[random.rand(STATUS_WEIGHTS.size)]

    category = case model.name
    when /Hilux|Amarok|S10|Ranger|Frontier/ then categories[2]
    when /RAV4|Tucson|Creta|CR-V|Sportage|Tracker|T-Cross|EcoSport|Kicks|X-Trail|Seltos|HR-V|Santa Fe|Territory|Land Cruiser/ then categories[1]
    when /Spin/ then categories[3]
    else categories[0]
    end

    year    = 2016 + random.rand(10)
    base    = 12_000 + random.rand(46_000)
    price   = (base / 100.0).round * 100

    vehicle = Vehicle.new(
      vehicle_model: model, year: year, price: price, mileage: random.rand(15) * 8_000 + 5_000
    )

    vehicle.assign_attributes(
      brand: model.brand,
      category: category,
      user: [ users[:seller], users[:seller_two], users[:admin] ][random.rand(3)],
      fuel_type: Vehicle.fuel_types.keys[random.rand(4)],
      transmission: Vehicle.transmissions.keys[random.rand(3)],
      engine: ENGINES[random.rand(ENGINES.size)],
      color: COLORS[random.rand(COLORS.size)],
      description: "#{model.brand.name} #{model.name} #{year} en excelente estado general. " \
                   "Mantenimiento al día en concesionario oficial, cubiertas nuevas y " \
                   "documentación lista para transferir. Recibimos usado en parte de pago " \
                   "y financiamos hasta 48 cuotas.",
      equipment: EQUIPMENT.sample(4 + random.rand(6), random: random).join("\n"),
      status: status,
      featured: random.rand(100) < 18,
      previous_price: (random.rand(100) < 30 ? price + 1_500 + random.rand(2_500) : nil),
      published_at: random.rand(120).days.ago,
      views_count: random.rand(400),
      meta_title: "#{model.brand.name} #{model.name} #{year} en venta",
      meta_description: "Comprá tu #{model.brand.name} #{model.name} #{year} en Playa Guaraní."
    )

    vehicle.save!
    created_vehicles << vehicle
  end
end

vehicles = Vehicle.kept.to_a
say "#{created_vehicles.size} vehículos nuevos (#{vehicles.size} en total)"

if photos_available
  attached = 0

  vehicles.select { |v| v.images.empty? }.each_with_index do |vehicle, index|
    (2 + (index % 3)).times do |photo_index|
      path = build_photo("#{vehicle.brand.name} #{vehicle.vehicle_model.name}", index + photo_index)
      next if path.blank?

      image = vehicle.images.new(alt_text: "#{vehicle.display_name} — foto #{photo_index + 1}")
      image.file.attach(io: File.open(path), filename: "#{vehicle.slug}-#{photo_index}.jpg",
                        content_type: "image/jpeg")
      image.save!
    end

    attached += 1
  end

  say "#{attached} vehículos con fotografías"
end

puts "\n== Ofertas =="

offer_candidates = Offer.count < 9 ? vehicles.select { |v| v.available? && v.offer.blank? }.first(9) : []
offers = offer_candidates.each_with_index.map do |vehicle, index|
  starts_on = (index * 3).days.ago.to_date
  Offer.create!(
    vehicle: vehicle,
    previous_price: vehicle.price,
    promo_price: (vehicle.price * (0.86 + (index % 3) * 0.02)).round(-1),
    starts_on: starts_on,
    ends_on: starts_on + (20 + index * 4).days,
    active: index < 7
  )
end
say "#{offers.size} ofertas"

puts "\n== Consultas =="

FIRST_NAMES = %w[Juan María Carlos Ana Diego Lucía Roberto Sofía Miguel Patricia
                 Fernando Claudia Gustavo Andrea Óscar Verónica Ramón Silvia].freeze
LAST_NAMES  = %w[González Rodríguez Martínez Benítez Villalba Ramírez Ortiz Duarte
                 Acosta Giménez Fernández Cáceres Riveros Sanabria Aquino].freeze

MESSAGES = [
  "Buenas, me interesa este vehículo. ¿Sigue disponible? ¿Aceptan usado en parte de pago?",
  "Hola, quisiera saber si financian y cuál sería la entrega inicial.",
  "¿Se puede coordinar una prueba de manejo para este fin de semana?",
  "Buen día, ¿el kilometraje es real y tienen el historial de service?",
  "Me interesa. ¿Cuál es el último precio de contado?",
  "¿Está en Asunción? ¿Puedo pasar a verlo hoy a la tarde?",
  nil
].freeze

INQUIRY_STATUSES = ([ :new_lead ] * 5 + [ :contacted ] * 4 + [ :negotiating ] * 3 +
                    [ :sold ] * 2 + [ :closed ] * 2).freeze

if Inquiry.count < 40
  90.times do |index|
    vehicle = random.rand(100) < 88 ? vehicles[random.rand(vehicles.size)] : nil
    status  = INQUIRY_STATUSES[random.rand(INQUIRY_STATUSES.size)]
    # Spread over six months so the dashboard chart has a real shape.
    created = random.rand(180).days.ago - random.rand(24).hours

    inquiry = Inquiry.new(
      vehicle: vehicle,
      user: (status == :new_lead ? nil : [ users[:seller], users[:seller_two] ][random.rand(2)]),
      name: "#{FIRST_NAMES[random.rand(FIRST_NAMES.size)]} #{LAST_NAMES[random.rand(LAST_NAMES.size)]}",
      email: (random.rand(100) < 70 ? "cliente#{index}@example.com" : nil),
      phone: "09#{random.rand(10)}#{random.rand(100..999)} #{random.rand(100..999)}",
      message: MESSAGES[random.rand(MESSAGES.size)],
      status: status,
      contacted_at: (status == :new_lead ? nil : created + 2.hours),
      closed_at: (%i[sold closed].include?(status) ? created + 3.days : nil),
      created_at: created,
      updated_at: created
    )
    inquiry.save!
  end
end
say "#{Inquiry.count} consultas"

puts "\n== Preguntas frecuentes =="

FAQS = [
  [ "¿Aceptan vehículos en parte de pago?",
    "Sí. Tasamos tu usado en el momento y lo tomamos como entrega inicial. Traelo con cédula verde y documentación al día." ],
  [ "¿Financian la compra?",
    "Trabajamos con varias entidades financieras y bancos. Podés financiar hasta 48 cuotas con una entrega desde el 30%." ],
  [ "¿Los vehículos tienen garantía?",
    "Todas las unidades salen con garantía de motor y caja por 3 meses o 5.000 km, lo que ocurra primero." ],
  [ "¿Puedo llevar el auto a mi mecánico de confianza?",
    "Por supuesto. Coordinamos una salida con vos para que lo revise antes de comprar." ],
  [ "¿Hacen la transferencia?",
    "Sí, nos ocupamos de todo el trámite de transferencia y te entregamos el vehículo a tu nombre." ],
  [ "¿Reciben motos?",
    "Recibimos motos en parte de pago según el modelo y el año. Consultanos por WhatsApp." ]
].freeze

FAQS.each_with_index do |(question, answer), index|
  Faq.find_or_initialize_by(question: question).tap do |faq|
    faq.assign_attributes(answer: answer, position: index, active: true)
    faq.save!
  end
end
say "#{Faq.count} preguntas"

puts "\n== Diferenciales =="

DIFFERENTIALS = [
  [ "Vehículos seleccionados", "Cada unidad pasa por una revisión de 60 puntos en nuestro taller antes de salir a la venta.", "check_circle" ],
  [ "Documentación transparente", "Verificamos títulos y deudas. Te mostramos todo antes de que firmes.", "file_text" ],
  [ "Financiación en el acto", "Trabajamos con bancos y financieras. Hasta 48 cuotas con entrega desde el 30%.", "percent" ],
  [ "Garantía escrita", "3 meses o 5.000 km de garantía de motor y caja en todas las unidades.", "shield" ],
  [ "Recibimos tu usado", "Lo tasamos en el momento y lo tomamos como parte de pago.", "car" ],
  [ "Atención personalizada", "Un vendedor te acompaña de la primera consulta hasta la transferencia.", "users" ]
].freeze

DIFFERENTIALS.each_with_index do |(title, description, icon), index|
  Differential.find_or_initialize_by(title: title).tap do |differential|
    differential.assign_attributes(description: description, icon: icon, position: index, active: true)
    differential.save!
  end
end
say "#{Differential.count} diferenciales"

# Counter caches can drift when records are created in bulk; recompute them so
# the dashboard and the catalogue agree.
puts "\n== Contadores =="
Brand.find_each { |b| Brand.reset_counters(b.id, :vehicles) }
Category.find_each { |c| Category.reset_counters(c.id, :vehicles) }
VehicleModel.find_each { |m| VehicleModel.reset_counters(m.id, :vehicles) }
Vehicle.find_each { |v| Vehicle.reset_counters(v.id, :inquiries) }
say "recalculados"

Current.user = nil

puts <<~SUMMARY

  ══════════════════════════════════════════════════════════════
   Datos de acceso (solo desarrollo)
  ══════════════════════════════════════════════════════════════
   Super Admin     admin@playaguarani.com.py
   Administrador   gerencia@playaguarani.com.py
   Vendedor        ventas@playaguarani.com.py
   Vendedora       rocio@playaguarani.com.py
   Editora         contenido@playaguarani.com.py

   Contraseña para todas: #{DEV_PASSWORD}
  ══════════════════════════════════════════════════════════════

SUMMARY
