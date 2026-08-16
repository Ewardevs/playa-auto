module Vehicles
  # Vehicles with a promotion that is actually running today.
  #
  # Joins the offer rather than trusting `vehicles.on_offer`: the flag is a
  # denormalised convenience, the dates are the truth.
  class OnOffer
    def self.call(...) = new(...).results

    def initialize(limit: nil, setting: Setting.current)
      @limit = limit
      @scope = Vehicles::Public.call(setting: setting)
    end

    def results
      relation = @scope.joins(:offer)
                       .merge(Offer.running)
                       .with_associations
                       .order("offers.ends_on ASC, vehicles.published_at DESC")

      @limit ? relation.limit(@limit) : relation
    end
  end
end
