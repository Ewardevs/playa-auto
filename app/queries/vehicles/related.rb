module Vehicles
  # "También podría interesarte" on a vehicle page.
  #
  # Relevance is ranked in SQL — same model beats same brand, which beats same
  # category, with a nearby price as the tie-breaker — so this stays a single
  # query no matter how much stock there is.
  class Related
    PRICE_BAND = 0.3

    def self.call(...) = new(...).results

    def initialize(vehicle, limit: 4, setting: Setting.current)
      @vehicle = vehicle
      @limit   = limit
      @scope   = Vehicles::Public.call(setting: setting)
    end

    def results
      @scope
        .where.not(id: @vehicle.id)
        .where(relevance_condition, **binds)
        .with_associations
        .order(Arel.sql(ranking), published_at: :desc)
        .limit(@limit)
    end

    private

    def relevance_condition
      "vehicle_model_id = :model OR brand_id = :brand OR category_id = :category " \
      "OR price BETWEEN :min_price AND :max_price"
    end

    def binds
      price = @vehicle.price.to_d

      {
        model: @vehicle.vehicle_model_id,
        brand: @vehicle.brand_id,
        category: @vehicle.category_id,
        min_price: price * (1 - PRICE_BAND),
        max_price: price * (1 + PRICE_BAND)
      }
    end

    def ranking
      Vehicle.sanitize_sql_array([
        "CASE WHEN vehicle_model_id = ? THEN 0 " \
        "WHEN brand_id = ? THEN 1 " \
        "WHEN category_id = ? THEN 2 ELSE 3 END",
        @vehicle.vehicle_model_id, @vehicle.brand_id, @vehicle.category_id
      ])
    end
  end
end
