# frozen_string_literal: true

module Site2
  # Resumen de lo que el visitante filtró, en fichas que se quitan de a una.
  #
  # Cada ficha es un enlace normal a la misma URL sin ese parámetro: se puede
  # abrir en otra pestaña, se puede compartir y no necesita JavaScript. Quitar
  # la marca arrastra también al modelo, porque un modelo sin su marca no
  # significa nada.
  class ActiveFiltersComponent < ApplicationComponent
    Chip = Struct.new(:label, :value, :path, keyword_init: true)

    def initialize(search:)
      @search = search
    end

    def render? = chips.any?

    private

    attr_reader :search

    def params = helpers.request.query_parameters

    def chips
      @chips ||= Vehicles::PublicSearch::FILTER_KEYS.filter_map { |key| chip_for(key) }
    end

    def chip_for(key)
      raw = params[key.to_s].presence
      return if raw.blank?

      value = display_value(key, raw)
      return if value.blank?

      Chip.new(label: label_for(key), value: value, path: path_without(key))
    end

    # Se quitan también `page` (el listado vuelve a empezar) y, con la marca, el
    # modelo que colgaba de ella.
    def path_without(key)
      dropped = [ key.to_s, "page" ]
      dropped << "modelo" if key == :marca

      helpers.site2_vehicles_path(params.except(*dropped))
    end

    def label_for(key) = t("site2.filters.#{LABEL_KEYS.fetch(key, key)}")

    LABEL_KEYS = {
      q: :text, marca: :brand, modelo: :model, categoria: :category,
      precio_min: :price, precio_max: :price, anio_min: :year, anio_max: :year,
      km_max: :mileage, combustible: :fuel, transmision: :transmission, estado: :status
    }.freeze

    # Se muestra lo que el visitante entiende (el nombre de la marca, el precio
    # formateado), no lo que viaja en la URL. Un valor que no existe en el
    # dominio devuelve nil y la ficha no se dibuja, igual que el filtro que el
    # query object ya había ignorado.
    def display_value(key, raw)
      case key
      when :q           then raw
      when :marca       then search.selected_brand&.name
      when :modelo      then model_name(raw)
      when :categoria   then search.selected_category&.name
      when :precio_min  then "#{t('site2.filters.price_min')} #{money(raw.to_i)}"
      when :precio_max  then "#{t('site2.filters.price_max')} #{money(raw.to_i)}"
      when :anio_min    then "#{t('site2.filters.year_min')} #{raw}"
      when :anio_max    then "#{t('site2.filters.year_max')} #{raw}"
      when :km_max      then "#{t('site2.filters.mileage_max')} #{mileage(raw.to_i)}"
      when :combustible then enum_label(:fuel_type, Vehicle.fuel_types, raw)
      when :transmision then enum_label(:transmission, Vehicle.transmissions, raw)
      when :estado      then status_label(raw)
      end
    end

    def model_name(slug)
      brand = search.selected_brand
      return if brand.blank?

      VehicleModel.active.find_by(slug: slug, brand_id: brand.id)&.name
    end

    def enum_label(attribute, definitions, value)
      return unless definitions.key?(value)

      Vehicle.human_enum_name(attribute, value)
    end

    def status_label(value)
      return unless value.in?(Vehicles::Public.new(setting: current_setting).visible_statuses)

      Vehicle.human_enum_name(:status, value)
    end
  end
end
