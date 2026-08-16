# frozen_string_literal: true

module Site2
  # La barra de filtros de Site2.
  #
  # Ni barra lateral ni cajón deslizante: una franja fija con el texto libre y
  # el orden, y debajo un panel a ancho completo que se despliega *en el flujo*
  # de la página y empuja los resultados hacia abajo. Es el mismo panel en el
  # teléfono y en el escritorio — no hay dos interacciones que mantener.
  #
  # El desplegable es un <details> nativo: se abre sin JavaScript, es accesible
  # de fábrica y llega abierto cuando el visitante ya venía filtrando.
  class FilterBarComponent < ApplicationComponent
    # Los campos que viven en el panel. Si alguno está activo el panel se abre
    # solo, para que nadie se pregunte de dónde salió un filtro que no ve.
    PANEL_KEYS = %i[
      marca modelo categoria precio_min precio_max anio_min anio_max
      km_max combustible transmision estado
    ].freeze

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

    def value_for(key) = params[key.to_s]

    def panel_open? = PANEL_KEYS.any? { |key| value_for(key).present? }

    def active_count = PANEL_KEYS.count { |key| value_for(key).present? }

    def brand_options     = brands.map { |brand| [ brand.name, brand.slug ] }
    def category_options  = categories.map { |category| [ category.name, category.slug ] }
    def model_options     = models.map { |model| [ model.name, model.slug ] }

    def fuel_options
      Vehicle.fuel_types.keys.map { |key| [ Vehicle.human_enum_name(:fuel_type, key), key ] }
    end

    def transmission_options
      Vehicle.transmissions.keys.map { |key| [ Vehicle.human_enum_name(:transmission, key), key ] }
    end

    # Solo los estados que el alcance público ya deja salir. Se le pregunta a la
    # propia frontera de seguridad en vez de repetir su criterio acá.
    def status_options
      Vehicles::Public.new(setting: current_setting).visible_statuses.map do |status|
        [ Vehicle.human_enum_name(:status, status), status ]
      end
    end

    def sort_options
      Vehicles::PublicSearch::SORTS.keys.map { |key| [ t("site2.sort.#{key}"), key ] }
    end

    def models_available? = models.any?

    def clear_path = helpers.site2_vehicles_path
  end
end
