module Vehicles
  # Turns the catalogue's query string into a relation.
  #
  # Filters compose, and every value is validated against the domain before it
  # reaches SQL: brands and categories are matched by slug, enums against their
  # own definitions, numbers coerced. An unknown value is ignored rather than
  # raising, because a query string is user input and a shared link may be old.
  #
  # Sorting is whitelisted — a visitor can never inject an ORDER BY.
  class PublicSearch
    SORTS = {
      "recientes" => { published_at: :desc, id: :desc },
      "precio-asc" => { price: :asc, id: :desc },
      "precio-desc" => { price: :desc, id: :desc },
      "anio-desc" => { year: :desc, id: :desc },
      "km-asc" => { mileage: :asc, id: :desc }
    }.freeze

    DEFAULT_SORT = "recientes".freeze

    def initialize(params: {}, scope: nil, setting: Setting.current)
      @params  = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
      @scope   = scope || Vehicles::Public.call(setting: setting)
      @setting = setting
    end

    def results
      relation = scope
      relation = by_text(relation)
      relation = by_brand(relation)
      relation = by_model(relation)
      relation = by_category(relation)
      relation = by_price(relation)
      relation = by_year(relation)
      relation = by_mileage(relation)
      relation = by_enum(relation, :fuel_type, Vehicle.fuel_types, param(:combustible))
      relation = by_enum(relation, :transmission, Vehicle.transmissions, param(:transmision))
      relation = by_status(relation)
      ordered(relation).with_associations
    end

    # True when the visitor narrowed the list — drives the empty state and the
    # "limpiar filtros" affordance.
    def filtered?
      FILTER_KEYS.any? { |key| param(key).present? }
    end

    def sort_key = SORTS.key?(param(:orden)) ? param(:orden) : DEFAULT_SORT

    # Memoised with `defined?` rather than `||=`: these legitimately resolve to
    # nil on an unfiltered catalogue, and `||=` would re-run the lookup on every
    # call.
    def selected_brand
      return @selected_brand if defined?(@selected_brand)

      @selected_brand = param(:marca) && Brand.active.find_by(slug: param(:marca))
    end

    def selected_category
      return @selected_category if defined?(@selected_category)

      @selected_category = param(:categoria) && Category.active.find_by(slug: param(:categoria))
    end

    FILTER_KEYS = %i[
      q marca modelo categoria precio_min precio_max anio_min anio_max
      km_max combustible transmision estado
    ].freeze

    private

    attr_reader :scope, :params

    def param(key) = params[key.to_s].presence

    def number(key)
      value = param(key)
      return if value.blank?

      digits = value.to_s.gsub(/[^\d]/, "")
      digits.presence&.to_i
    end

    def by_text(relation)
      term = param(:q)
      return relation if term.blank?

      pattern = "%#{Vehicle.sanitize_sql_like(term)}%"

      relation.left_joins(:brand, :vehicle_model).where(
        "vehicles.color ILIKE :q OR vehicles.engine ILIKE :q " \
        "OR brands.name ILIKE :q OR vehicle_models.name ILIKE :q " \
        "OR (brands.name || ' ' || vehicle_models.name) ILIKE :q",
        q: pattern
      )
    end

    def by_brand(relation)
      selected_brand ? relation.where(brand_id: selected_brand.id) : relation
    end

    def by_model(relation)
      slug = param(:modelo)
      return relation if slug.blank?

      model = VehicleModel.active.find_by(slug: slug, brand_id: selected_brand&.id)
      model ? relation.where(vehicle_model_id: model.id) : relation
    end

    def by_category(relation)
      selected_category ? relation.where(category_id: selected_category.id) : relation
    end

    def by_price(relation)
      relation = relation.where(price: number(:precio_min)..) if number(:precio_min)
      relation = relation.where(price: ..number(:precio_max)) if number(:precio_max)
      relation
    end

    def by_year(relation)
      relation = relation.where(year: number(:anio_min)..) if number(:anio_min)
      relation = relation.where(year: ..number(:anio_max)) if number(:anio_max)
      relation
    end

    def by_mileage(relation)
      number(:km_max) ? relation.where(mileage: ..number(:km_max)) : relation
    end

    def by_enum(relation, column, definitions, value)
      return relation unless value && definitions.key?(value)

      relation.where(column => value)
    end

    # Narrowing only: a visitor may filter *within* what is already public, and
    # can never reach a status Vehicles::Public excluded.
    def by_status(relation)
      value = param(:estado)
      return relation unless value.in?(Vehicles::Public.new.visible_statuses)

      relation.where(status: value)
    end

    def ordered(relation) = relation.order(SORTS.fetch(sort_key))
  end
end
