# frozen_string_literal: true

module Site4
  # Portada editorial.
  #
  # Composición asimétrica de doble página: el titular y el buscador a la
  # izquierda, una unidad real con sus datos a la derecha y las cifras de la
  # playa debajo. El texto sale de SiteContent; lo único fijo es el andamiaje.
  class HeroComponent < ApplicationComponent
    def initialize(vehicle:, categories:, category_stock:, stock_count:, brand_count:, offer_count:)
      @vehicle       = vehicle
      @categories    = categories
      @category_stock = category_stock
      @stock_count   = stock_count
      @brand_count   = brand_count
      @offer_count   = offer_count
    end

    private

    attr_reader :vehicle, :categories, :category_stock, :stock_count, :brand_count, :offer_count

    def title = site_content.hero_title.presence || t("site4.home.hero_title_fallback")

    def subtitle = site_content.hero_subtitle.presence

    def button_label = site_content.hero_button_label.presence || t("site4.cta.explore")

    def button_url
      return @button_url if defined?(@button_url)

      @button_url = resolve_button_url
    end

    # El botón lo configura la playa desde el panel. Una ruta del sitio como
    # "/vehiculos" pertenece a esta web: hay que resolverla a /v4/vehiculos. Una
    # URL absoluta se deja tal cual.
    def resolve_button_url
      url = site_content.hero_button_url.to_s.strip
      return url if url.blank?
      return url if url.match?(%r{\Ahttps?://}i)
      return url if url.start_with?("//")

      helpers.site4_root_path + url.sub(/\A\//, "")
    end

    def poster
      return unless vehicle.present?

      image = vehicle.main_image
      return unless image&.file&.attached?

      image.file.variant(:large)
    end

    def poster_alt
      return unless vehicle.present?

      t("site4.home.featured_photo_alt", vehicle: vehicle.display_name)
    end

    def shortcuts
      @shortcuts ||= categories.filter_map do |category|
        [ category, category_stock[category.id].to_i ] if category_stock[category.id].to_i.positive?
      end
    end

    def stats
      [
        [ t("site4.home.stat_stock"), number(stock_count) ],
        [ t("site4.home.stat_brands"), number(brand_count) ],
        [ t("site4.home.stat_offers"), number(offer_count) ]
      ]
    end

    def number(value) = number_with_delimiter(value, delimiter: ".")
  end
end
