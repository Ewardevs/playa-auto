# frozen_string_literal: true

module Site4
  # Riel de filtros del catálogo.
  #
  # Facetas con contadores honestos —cada cuenta responde "cuántos resultados
  # habría si eligieras esta opción"— y fichas removibles para cada filtro
  # activo. En escritorio es un panel en flujo; en móvil el controlador
  # Stimulus lo convierte en una hoja que sube desde abajo, y sin JavaScript el
  # mismo panel se muestra arriba de los resultados.
  class FilterRailComponent < ApplicationComponent
    def initialize(search:, brands:, categories:, models:, brand_counts: {},
                   category_counts: {}, fuel_counts: {}, transmission_counts: {},
                   model_counts: {}, active_filters: [], total: 0)
      @search             = search
      @brands             = brands
      @categories         = categories
      @models             = models
      @brand_counts       = brand_counts
      @category_counts    = category_counts
      @fuel_counts        = fuel_counts
      @transmission_counts = transmission_counts
      @model_counts       = model_counts
      @active_filters     = active_filters
      @total              = total
    end

    private

    attr_reader :search, :brands, :categories, :models, :brand_counts,
                :category_counts, :fuel_counts, :transmission_counts,
                :model_counts, :active_filters, :total

    def selected_brand_slug = helpers.params[:marca]

    def selected_model_slug = helpers.params[:modelo]

    def selected_category_slug = helpers.params[:categoria]

    def selected_fuel = helpers.params[:combustible]

    def selected_transmission = helpers.params[:transmision]

    def selected_status = helpers.params[:estado]

    def brand_options = options(brands, brand_counts)

    def category_options = options(categories, category_counts)

    def model_options = options(models, model_counts)

    def options(records, counts)
      records.map do |record|
        [ "#{record.name} · #{counts[record.id].to_i}", record.slug ]
      end
    end

    def fuel_options
      Vehicle.fuel_types.keys.map do |key|
        [ "#{Vehicle.human_enum_name(:fuel_type, key)} · #{fuel_counts[key].to_i}", key ]
      end
    end

    def transmission_options
      Vehicle.transmissions.keys.map do |key|
        [ "#{Vehicle.human_enum_name(:transmission, key)} · #{transmission_counts[key].to_i}", key ]
      end
    end

    def status_options
      Vehicles::Public.new.visible_statuses.map do |status|
        [ Vehicle.human_enum_name(:status, status), status ]
      end
    end

    def sort_options
      Vehicles::PublicSearch::SORTS.keys.map { |key| [ t("site4.sort.#{key}"), key ] }
    end

    def sort_key = search.sort_key

    def filtered? = search.filtered?

    def field_class
      "w-full h-12 px-4 rounded-[0.875rem] bg-s4-surface-2 border border-[color:rgba(17,19,21,0.08)] " \
      "text-[0.9375rem] text-s4-ink focus:outline-none focus:ring-2 focus:ring-s4-accent/30 " \
      "transition-shadow"
    end

    def label_class = "block text-[0.8125rem] font-medium text-s4-ink-2 mb-1.5"
  end
end
