# frozen_string_literal: true

module Site2
  # Portada.
  #
  # El texto no va encima de una fotografía: va al lado. La columna izquierda es
  # tipografía sobre el fondo negro —siempre legible, sin degradados que tapen
  # la mitad de la imagen— y la derecha muestra dos unidades reales del stock,
  # una detrás de la otra. Lo que se ve al entrar es inventario, no un montaje.
  class HeroComponent < ApplicationComponent
    def initialize(vehicles:, stock_count:, brand_count:, offer_count:)
      @vehicles    = Array(vehicles).first(2)
      @stock_count = stock_count
      @brand_count = brand_count
      @offer_count = offer_count
    end

    private

    attr_reader :vehicles, :stock_count, :brand_count, :offer_count

    def title = site_content.hero_title.presence || t("site2.home.hero_title_fallback")

    def subtitle = site_content.hero_subtitle.presence || current_setting.tagline.presence

    def body = site_content.hero_text

    def button_label = site_content.hero_button_label.presence || t("site2.cta.explore")

    # El destino del botón se carga en el panel como un path ("/vehiculos"), y
    # ese path significa "el catálogo" — no "el catálogo del otro sitio". Cada
    # sitio lo resuelve dentro de su propio espacio, así el mismo contenido
    # administrado sirve a los dos sin mandar visitantes de uno al otro.
    #
    # Una URL absoluta (una campaña, un sitio externo) se respeta tal cual, y un
    # path que no reconocemos también: no es asunto nuestro reescribirlo.
    LOCAL_EQUIVALENTS = {
      "/" => :site2_root_path,
      "/vehiculos" => :site2_vehicles_path,
      "/ofertas" => :site2_offers_path,
      "/nosotros" => :site2_about_path,
      "/preguntas-frecuentes" => :site2_faqs_path,
      "/contacto" => :site2_contact_path
    }.freeze

    def button_url
      configured = site_content.hero_button_url.presence
      return helpers.site2_vehicles_path if configured.blank?

      helper = LOCAL_EQUIVALENTS[configured.split("?").first.chomp("/").presence || "/"]
      helper ? helpers.public_send(helper) : configured
    end

    def whatsapp_url = Vehicles::WhatsappMessage.new(setting: current_setting).link

    def lead_vehicle   = vehicles.first
    def second_vehicle = vehicles.second

    def stats
      [
        [ t("site2.home.hero_stat_stock"),  number(stock_count) ],
        [ t("site2.home.hero_stat_brands"), number(brand_count) ],
        [ t("site2.home.hero_stat_offers"), number(offer_count) ]
      ]
    end

    def number(value) = helpers.number_with_delimiter(value, delimiter: ".")

    def poster_for(vehicle)
      image = vehicle&.main_image
      return unless image&.file&.attached?

      image.file.variant(:poster)
    end
  end
end
