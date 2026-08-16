module Vehicles
  # Copies a vehicle so a near-identical unit can be listed in seconds.
  #
  # Deliberately does not copy: the internal code and slug (regenerated), the
  # photos (they belong to a specific unit), the offer, the inquiries or the
  # metrics. The copy starts hidden so it is never published by accident.
  class Duplicate
    IGNORED = %w[
      id code slug created_at updated_at discarded_at
      views_count inquiries_count published_at
    ].freeze

    def initialize(vehicle, user: Current.user)
      @vehicle = vehicle
      @user    = user
    end

    def call
      copy = Vehicle.new(@vehicle.attributes.except(*IGNORED))
      copy.status   = :hidden
      copy.featured = false
      copy.on_offer = false
      copy.user     = @user
      copy.published_at = nil

      copy.save!
      copy.log_audit(:duplicated, changes: { "origen" => [ @vehicle.code, copy.code ] })
      copy
    end
  end
end
