# frozen_string_literal: true

module Site2
  # La card de Site2: un afiche vertical.
  #
  # La fotografía ocupa toda la pieza y los datos van encima, sobre un degradado
  # —no debajo, en un panel blanco—. El precio es lo más grande de la card
  # después de la propia foto, porque es lo primero que el comprador busca.
  class VehicleCardComponent < ApplicationComponent
    def initialize(vehicle:, index: nil, loading: "lazy", priority: false)
      @vehicle  = vehicle
      @index    = index
      @loading  = loading
      @priority = priority
    end

    private

    attr_reader :vehicle, :index, :loading

    def path = helpers.site2_vehicle_path(vehicle)

    def title = "#{vehicle.brand.name} #{vehicle.vehicle_model.name}".squish

    def image = @image ||= vehicle.main_image

    def image? = image&.file&.attached?

    def image_alt = t("site2.vehicles.photo_alt", vehicle: vehicle.display_name)

    def fetch_priority = @priority ? "high" : "auto"

    def discounted? = vehicle.discounted?

    def sold? = vehicle.status == "sold"

    def offer_ends_on = vehicle.running_offer&.ends_on

    def index_label = index && format("%02d", index)

    # Tres datos, siempre los mismos y siempre en el mismo orden: es lo que
    # permite comparar dos cards de un vistazo.
    def stats
      [
        [ t("site2.vehicles.spec_year"), vehicle.year.to_s ],
        [ t("site2.vehicles.spec_mileage"), mileage(vehicle.mileage) ],
        [ t("site2.vehicles.spec_transmission"),
          Vehicle.human_enum_name(:transmission, vehicle.transmission) ]
      ]
    end
  end
end
