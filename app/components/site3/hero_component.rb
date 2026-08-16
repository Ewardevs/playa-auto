# frozen_string_literal: true

module Site3
  # Portada, en mosaico.
  #
  # No hay un hero: hay una grilla de piezas de distinto tamaño —el titular con
  # el buscador, una unidad real del stock, las cifras de la playa— cada una en
  # su propia superficie. Es el patrón con el que hoy se abre un producto, y es
  # lo contrario de los otros dos sitios: uno pone el texto sobre una fotografía
  # a sangre, el otro lo pone al lado. Acá el contenido está en cajas que se
  # pueden reordenar sin que la página se caiga.
  class HeroComponent < ApplicationComponent
    def initialize(vehicle:, categories:, category_stock:, stock_count:, brand_count:, offer_count:)
      @vehicle        = vehicle
      @categories     = Array(categories)
      @category_stock = category_stock || {}
      @stock_count    = stock_count
      @brand_count    = brand_count
      @offer_count    = offer_count
    end

    private

    attr_reader :vehicle, :categories, :category_stock, :stock_count, :brand_count, :offer_count

    def title = site_content.hero_title.presence || t("site3.home.hero_title_fallback")

    def subtitle = site_content.hero_subtitle.presence || current_setting.tagline.presence

    # Los segmentos que tienen stock de verdad. Uno vacío no se ofrece: nadie
    # debería llegar a un catálogo sin resultados desde la portada.
    def shortcuts
      categories.filter_map do |category|
        count = category_stock[category.id].to_i
        [ category, count ] if count.positive?
      end.first(5)
    end

    def button_label = site_content.hero_button_label.presence || t("site3.cta.explore")

    # El destino se carga en el panel como un path ("/vehiculos"), y ese path
    # significa "el catálogo" — no "el catálogo de otro sitio". Cada sitio lo
    # resuelve dentro de su propio espacio. Una URL absoluta (una campaña, un
    # sitio externo) se respeta tal cual, y un path que no reconocemos también:
    # no es asunto nuestro reescribirlo.
    LOCAL_EQUIVALENTS = {
      "/" => :site3_root_path,
      "/vehiculos" => :site3_vehicles_path,
      "/ofertas" => :site3_offers_path,
      "/nosotros" => :site3_about_path,
      "/preguntas-frecuentes" => :site3_faqs_path,
      "/contacto" => :site3_contact_path
    }.freeze

    def button_url
      configured = site_content.hero_button_url.presence
      return helpers.site3_vehicles_path if configured.blank?

      helper = LOCAL_EQUIVALENTS[configured.split("?").first.chomp("/").presence || "/"]
      helper ? helpers.public_send(helper) : configured
    end

    def stats
      [
        [ t("site3.home.stat_stock"),  stock_count ],
        [ t("site3.home.stat_brands"), brand_count ],
        [ t("site3.home.stat_offers"), offer_count ]
      ]
    end

    def number(value) = helpers.number_with_delimiter(value, delimiter: ".")

    def poster
      image = vehicle&.main_image
      return unless image&.file&.attached?

      image.file.variant(:poster)
    end
  end
end
