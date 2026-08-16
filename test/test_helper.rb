ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Ejecuta los tests en paralelo contra la misma base; cada worker tiene su
    # propia transacción.
    parallelize(workers: :number_of_processors)
  end
end

# Los tests del sitio público golpean el servidor como un navegador real:
# `allow_browser versions: :modern` rechaza con 403 cualquier request sin un
# User-Agent moderno, así que todas las peticiones de request tests lo llevan.
module BrowserHelper
  BROWSER_UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 " \
               "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

  def get_browser(path, headers: {}, **kwargs)
    get path, **kwargs, headers: { "User-Agent" => BROWSER_UA }.merge(headers)
  end

  def post_browser(path, headers: {}, **kwargs)
    post path, **kwargs, headers: { "User-Agent" => BROWSER_UA }.merge(headers)
  end
end

# Datos mínimos para que un request del sitio público funcione. No hay fixtures:
# cada test arma lo suyo dentro de su transacción y se limpia solo.
module PlaygroundData
  def playa_setting!
    Setting.current.update!(
      company_name: "Playa Test",
      currency: "PYG",
      whatsapp: "0981111222",
      email: "hola@playa.test",
      address: "Av. Mariscal López 1234",
      tagline: "Autos usados seleccionados"
    )
    SiteContent.current.update!(hero_title: "Un auto elegido para vos")
  end

  def make_brand(name = "Toyota")
    Brand.create!(name: name)
  end

  def make_category(name = "SUV")
    Category.create!(name: name)
  end

  def make_model(brand, name = "RAV4")
    VehicleModel.create!(brand: brand, name: name)
  end

  def make_vehicle(brand:, category:, model:, **attrs)
    Vehicle.create!(
      brand: brand,
      vehicle_model: model,
      category: category,
      year: 2022,
      mileage: 25_000,
      fuel_type: "gasoline",
      transmission: "automatic",
      status: "available",
      price: 25_000_000,
      description: "Unidad de prueba para el catálogo.",
      **attrs
    )
  end

  def make_faq
    Faq.create!(question: "¿Financian?",
                answer: "Sí, coordinamos financiación directa.",
                position: 1)
  end

  def make_differential
    Differential.create!(title: "Vehículos seleccionados",
                         description: "Cada unidad pasa una revisión.",
                         icon: "check_circle",
                         position: 1)
  end

  def make_offer(vehicle, promo_price: 20_000_000)
    vehicle.update!(price: 25_000_000)
    vehicle.create_offer!(promo_price: promo_price,
                          starts_on: Date.current - 1.day,
                          ends_on: Date.current + 10.days)
  end
end

class Site4RequestTest < ActionDispatch::IntegrationTest
  include BrowserHelper
  include PlaygroundData

  setup do
    playa_setting!

    @brand    = make_brand("Toyota")
    @category = make_category("SUV")
    @model    = make_model(@brand, "RAV4")
    @vehicle  = make_vehicle(brand: @brand, category: @category, model: @model)
  end
end
