module Vehicles
  # Turns the vehicle list's query string into a relation.
  #
  # All filtering lives here so the controller stays thin and the same rules can
  # back the future public catalogue. Every filter is optional and they compose;
  # unknown values are ignored rather than raising, because a query string is
  # user input and must never be trusted.
  class Search
    SORTABLE = {
      "code" => :code,
      "year" => :year,
      "price" => :price,
      "mileage" => :mileage,
      "status" => :status,
      "created_at" => :created_at,
      "published_at" => :published_at
    }.freeze

    DEFAULT_SORT = "created_at".freeze

    def initialize(scope: Vehicle.all, params: {})
      @scope  = scope
      @params = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
    end

    def results
      relation = archived_scope
      relation = by_text(relation)
      relation = by_brand(relation)
      relation = by_model(relation)
      relation = by_category(relation)
      relation = by_status(relation)
      relation = by_flag(relation)
      relation = by_year(relation)
      relation = by_price(relation)
      ordered(relation)
    end

    private

    attr_reader :scope, :params

    def param(key) = params[key.to_s].presence

    # Archived stock is hidden unless explicitly asked for.
    def archived_scope
      param(:archived) == "1" ? scope.discarded : scope.kept
    end

    def by_text(relation)
      term = param(:q)
      return relation if term.blank?

      pattern = "%#{Vehicle.sanitize_sql_like(term)}%"

      relation.left_joins(:brand, :vehicle_model).where(
        "vehicles.code ILIKE :q OR vehicles.color ILIKE :q OR vehicles.engine ILIKE :q " \
        "OR brands.name ILIKE :q OR vehicle_models.name ILIKE :q " \
        "OR (brands.name || ' ' || vehicle_models.name) ILIKE :q",
        q: pattern
      )
    end

    def by_brand(relation)
      value = param(:brand_id)
      value ? relation.where(brand_id: value) : relation
    end

    def by_model(relation)
      value = param(:vehicle_model_id)
      value ? relation.where(vehicle_model_id: value) : relation
    end

    def by_category(relation)
      value = param(:category_id)
      value ? relation.where(category_id: value) : relation
    end

    def by_status(relation)
      value = param(:status)
      return relation unless value && Vehicle.statuses.key?(value)

      relation.where(status: value)
    end

    # `featured` and `on_offer` arrive as "1"/"0"; anything else means "no filter".
    def by_flag(relation)
      relation = flag(relation, :featured, param(:featured))
      flag(relation, :on_offer, param(:offer))
    end

    def flag(relation, column, value)
      case value
      when "1" then relation.where(column => true)
      when "0" then relation.where(column => false)
      else relation
      end
    end

    def by_year(relation)
      relation = relation.where(year: param(:year_from)..) if param(:year_from)
      relation = relation.where(year: ..param(:year_to)) if param(:year_to)
      relation
    end

    def by_price(relation)
      relation = relation.where(price: param(:price_from)..) if param(:price_from)
      relation = relation.where(price: ..param(:price_to)) if param(:price_to)
      relation
    end

    def ordered(relation)
      column    = SORTABLE.fetch(param(:sort), SORTABLE[DEFAULT_SORT])
      direction = param(:dir) == "asc" ? :asc : :desc

      relation.order(column => direction, :id => :desc)
    end
  end
end
