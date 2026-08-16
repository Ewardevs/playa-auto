# frozen_string_literal: true

module Site4
  # Card del catálogo.
  #
  # La fotografía sangra hasta el borde de la superficie y los datos viajan en
  # chips translúcidos que flotan sobre ella: la firma de este sitio. El título
  # y el precio viven en la superficie blanda de abajo.
  class VehicleCardComponent < ApplicationComponent
    def initialize(vehicle:, loading: "lazy", priority: false)
      @vehicle  = vehicle
      @loading  = loading
      @priority = priority
    end

    private

    attr_reader :vehicle, :loading

    def path = helpers.site4_vehicle_path(vehicle)

    def title = "#{vehicle.brand.name} #{vehicle.vehicle_model.name}"

    def image = vehicle.main_image

    def image? = image.present? && image.file.attached?

    def image_alt
      t("site4.vehicles.photo_alt", vehicle: vehicle.display_name)
    end

    def fetch_priority = @priority ? "high" : "auto"

    def sold? = vehicle.status == "sold"

    def discounted? = vehicle.discounted?

    def savings
      return unless discounted?

      amount = vehicle.price.to_d - vehicle.current_price.to_d
      amount.positive? ? amount : nil
    end

    def offer_ends_on = vehicle.running_offer&.ends_on

    # La "chapa flotante": los datos con los que se compara una unidad. Va
    # encima de la foto, no debajo.
    def floating_specs
      [
        vehicle.year.to_s,
        helpers.mileage(vehicle.mileage),
        Vehicle.human_enum_name(:transmission, vehicle.transmission)
      ]
    end
  end
end
