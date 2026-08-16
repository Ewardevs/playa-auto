# frozen_string_literal: true

module Site3
  # Riel de filtros.
  #
  # Ni barra lateral con cajón (Site1) ni panel a ancho completo que empuja los
  # resultados (Site2): acá cada filtro es una píldora que abre su propio
  # desplegable justo debajo, como los controles de una aplicación. La píldora
  # muestra el valor elegido, así el estado del filtro se lee sin abrir nada.
  #
  # Cada desplegable es un <details> nativo: abre, cierra y se anuncia solo. El
  # controlador Stimulus únicamente cierra el anterior al abrir otro y envía el
  # formulario al elegir una opción — sin JavaScript sigue funcionando entero.
  class FilterRailComponent < ApplicationComponent
    def initialize(search:, brands:, categories:, models:, total:)
      @search     = search
      @brands     = brands
      @categories = categories
      @models     = models
      @total      = total
    end

    private

    attr_reader :search, :brands, :categories, :models, :total

    def params = helpers.request.query_parameters

    def value_for(key) = params[key.to_s].presence

    def any?(*keys) = keys.any? { |key| value_for(key).present? }

    # La píldora se tiñe cuando el filtro está puesto: el estado se ve sin abrir.
    def pill_class(active)
      base = "inline-flex items-center gap-2 h-11 px-4 rounded-full text-sm cursor-pointer " \
             "select-none transition-colors list-none [&::-webkit-details-marker]:hidden"

      active ? "#{base} bg-s3-accent text-white" : "#{base} bg-s3-surface text-s3-ink-2 hover:text-s3-ink"
    end

    def popover_class
      "absolute left-0 top-full mt-2 z-40 w-[min(20rem,calc(100vw-2rem))] " \
      "s3-float rounded-s3 p-5"
    end

    def field_class
      "w-full h-10 px-3 rounded-s3-sm bg-s3-canvas border-0 text-sm text-s3-ink " \
      "focus:outline-none focus:ring-2 focus:ring-s3-accent/30"
    end

    def label_class = "s3-label block mb-1.5"

    def brand_options    = brands.map { |brand| [ brand.name, brand.slug ] }
    def category_options = categories.map { |category| [ category.name, category.slug ] }
    def model_options    = models.map { |model| [ model.name, model.slug ] }

    def fuel_options
      Vehicle.fuel_types.keys.map { |key| [ Vehicle.human_enum_name(:fuel_type, key), key ] }
    end

    def transmission_options
      Vehicle.transmissions.keys.map { |key| [ Vehicle.human_enum_name(:transmission, key), key ] }
    end

    # Solo los estados que el alcance público ya deja salir: se le pregunta a la
    # propia frontera de seguridad en vez de repetir su criterio acá.
    def status_options
      Vehicles::Public.new(setting: current_setting).visible_statuses.map do |status|
        [ Vehicle.human_enum_name(:status, status), status ]
      end
    end

    def sort_options
      Vehicles::PublicSearch::SORTS.keys.map { |key| [ t("site3.sort.#{key}"), key ] }
    end

    def models_available? = models.any?

    # Lo que muestra la píldora: el nombre elegido, no el slug que viaja en la URL.
    def brand_pill = search.selected_brand&.name || t("site3.filters.brand")

    def category_pill = search.selected_category&.name || t("site3.filters.category")

    def model_pill
      slug = value_for(:modelo)
      return t("site3.filters.model") if slug.blank?

      models.find { |model| model.slug == slug }&.name || t("site3.filters.model")
    end

    def price_pill
      return t("site3.filters.price") unless any?(:precio_min, :precio_max)

      [ value_for(:precio_min) && "#{t('site3.filters.price_min')} #{money(value_for(:precio_min).to_i)}",
        value_for(:precio_max) && "#{t('site3.filters.price_max')} #{money(value_for(:precio_max).to_i)}" ]
        .compact.join(" · ")
    end

    def year_pill
      return t("site3.filters.year") unless any?(:anio_min, :anio_max)

      [ value_for(:anio_min), value_for(:anio_max) ].compact.join(" – ")
    end

    def mileage_pill
      return t("site3.filters.mileage") unless any?(:km_max)

      "#{t('site3.filters.mileage_max')} #{mileage(value_for(:km_max).to_i)}"
    end

    def enum_pill(key, definitions, attribute, fallback)
      value = value_for(key)
      return fallback unless value && definitions.key?(value)

      Vehicle.human_enum_name(attribute, value)
    end

    def fuel_pill
      enum_pill(:combustible, Vehicle.fuel_types, :fuel_type, t("site3.filters.fuel"))
    end

    def transmission_pill
      enum_pill(:transmision, Vehicle.transmissions, :transmission, t("site3.filters.transmission"))
    end

    def status_pill
      value = value_for(:estado)
      allowed = Vehicles::Public.new(setting: current_setting).visible_statuses
      return t("site3.filters.status") unless value&.in?(allowed)

      Vehicle.human_enum_name(:status, value)
    end

    def sort_pill = t("site3.sort.#{search.sort_key}")

    def clear_path = helpers.site3_vehicles_path

    # Quitar un filtro es un clic, no "abrir el desplegable y elegir
    # cualquiera": cuando la píldora está activa le crece una mitad con la ×.
    #
    # Es un enlace normal a la misma URL sin ese parámetro — se puede abrir en
    # otra pestaña, se puede compartir y no necesita JavaScript. Va al lado del
    # <summary> y no adentro, porque un enlace dentro de un summary pelea con el
    # gesto que abre el desplegable.
    def remove_link(*keys, label:)
      return unless keys.any? { |key| value_for(key).present? }

      link_to(remove_path(*keys),
              class: "grid place-items-center w-9 -ml-px rounded-r-full bg-s3-accent " \
                     "text-white/70 transition-colors hover:text-white",
              aria: { label: t("site3.filters.remove", label: label) }) do
        render UI::IconComponent.new(:x, class: "size-3.5")
      end
    end

    # Quitar la marca arrastra al modelo: un modelo sin su marca no significa
    # nada. Se quita también `page`, porque el listado vuelve a empezar.
    def remove_path(*keys)
      dropped = keys.map(&:to_s) + [ "page" ]
      dropped << "modelo" if keys.include?(:marca)

      helpers.site3_vehicles_path(params.except(*dropped))
    end

    # La píldora activa pierde su esquina derecha para pegarse a la ×.
    def pill_class_for(active)
      active ? "#{pill_class(true)} rounded-r-none" : pill_class(false)
    end
  end
end
