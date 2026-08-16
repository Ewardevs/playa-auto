# frozen_string_literal: true

module Site3
  # Ficha técnica como lista de propiedades de producto: etiqueta a la
  # izquierda, valor a la derecha, separadas por una línea casi invisible. Un
  # campo que la playa no cargó no aparece.
  class VehicleSpecsComponent < ApplicationComponent
    def initialize(vehicle:)
      @vehicle = vehicle
    end

    private

    attr_reader :vehicle

    def rows
      [
        [ t("site3.vehicles.spec_year"),         vehicle.year.to_s ],
        [ t("site3.vehicles.spec_mileage"),      mileage(vehicle.mileage) ],
        [ t("site3.vehicles.spec_transmission"), Vehicle.human_enum_name(:transmission, vehicle.transmission) ],
        [ t("site3.vehicles.spec_fuel"),         Vehicle.human_enum_name(:fuel_type, vehicle.fuel_type) ],
        [ t("site3.vehicles.spec_brand"),        vehicle.brand.name ],
        [ t("site3.vehicles.spec_model"),        vehicle.vehicle_model.name ],
        [ t("site3.vehicles.spec_category"),     vehicle.category.name ],
        [ t("site3.vehicles.spec_engine"),       vehicle.engine ],
        [ t("site3.vehicles.spec_color"),        vehicle.color ]
      ].select { |_label, value| value.present? }
    end
  end
end
