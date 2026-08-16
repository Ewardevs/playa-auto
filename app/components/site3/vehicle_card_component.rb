# frozen_string_literal: true

module Site3
  # La card de Site3: una superficie que flota, con la fotografía *encastrada*.
  #
  # La foto no llega a los bordes de la pieza — vive dentro, con su propio radio
  # y un margen que la separa del blanco. Es la diferencia entre una card de
  # catálogo impreso (Site1, foto al ras arriba) y una ficha de producto de
  # software, que es lo que este sitio quiere parecer.
  #
  # Los datos van en píldoras, no en una chapa monoespaciada ni en bloques de
  # cifra grande: son etiquetas de producto.
  class VehicleCardComponent < ApplicationComponent
    def initialize(vehicle:, loading: "lazy", priority: false)
      @vehicle  = vehicle
      @loading  = loading
      @priority = priority
    end

    private

    attr_reader :vehicle, :loading

    def path = helpers.site3_vehicle_path(vehicle)

    def title = "#{vehicle.brand.name} #{vehicle.vehicle_model.name}".squish

    def image = @image ||= vehicle.main_image

    def image? = image&.file&.attached?

    def image_alt = t("site3.vehicles.photo_alt", vehicle: vehicle.display_name)

    def fetch_priority = @priority ? "high" : "auto"

    def discounted? = vehicle.discounted?

    def sold? = vehicle.status == "sold"

    # Lo que el comprador se ahorra, en plata. Un porcentaje obliga a hacer una
    # cuenta; un monto no.
    def savings
      return unless discounted?

      difference = vehicle.price.to_d - vehicle.current_price.to_d
      difference.positive? ? difference : nil
    end

    def offer_ends_on = vehicle.running_offer&.ends_on

    def specs
      [
        vehicle.year.to_s,
        mileage(vehicle.mileage),
        Vehicle.human_enum_name(:transmission, vehicle.transmission),
        Vehicle.human_enum_name(:fuel_type, vehicle.fuel_type)
      ].compact_blank
    end
  end
end
