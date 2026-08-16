# frozen_string_literal: true

module Site4
  # Ficha técnica de la unidad.
  #
  # Filas con etiqueta y valor sobre la superficie blanda; los valores en tabular
  # para que los números no bailen al comparar dos fichas. Los datos que la
  # playa no cargó se omiten, nunca se inventan.
  class VehicleSpecsComponent < ApplicationComponent
    def initialize(vehicle:)
      @vehicle = vehicle
    end

    private

    attr_reader :vehicle

    def rows
      [
        [ t("site4.vehicles.spec_brand"),      vehicle.brand&.name ],
        [ t("site4.vehicles.spec_model"),      vehicle.vehicle_model&.name ],
        [ t("site4.vehicles.spec_year"),       vehicle.year.to_s ],
        [ t("site4.vehicles.spec_mileage"),    helpers.mileage(vehicle.mileage) ],
        [ t("site4.vehicles.spec_category"),   vehicle.category&.name ],
        [ t("site4.vehicles.spec_transmission"), Vehicle.human_enum_name(:transmission, vehicle.transmission) ],
        [ t("site4.vehicles.spec_fuel"),       Vehicle.human_enum_name(:fuel_type, vehicle.fuel_type) ],
        [ t("site4.vehicles.spec_color"),      vehicle.color.presence ],
        [ t("site4.vehicles.spec_engine"),     vehicle.engine.presence ]
      ].reject { |_label, value| value.blank? }
    end
  end
end
