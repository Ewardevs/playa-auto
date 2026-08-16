module Vehicles
  # Applies a new photo order.
  #
  # Only ids that actually belong to this vehicle are honoured, so a tampered
  # request can never reorder — or touch — another vehicle's photos.
  class ReorderImages
    def initialize(vehicle, ids:)
      @vehicle = vehicle
      @ids     = ids
    end

    def call
      owned = @vehicle.images.pluck(:id)
      ordered = (@ids & owned) + (owned - @ids)

      VehicleImage.transaction do
        ordered.each_with_index do |id, index|
          VehicleImage.where(id: id).update_all(position: index, updated_at: Time.current)
        end
      end

      @vehicle.touch
      ordered
    end
  end
end
