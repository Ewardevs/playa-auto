# frozen_string_literal: true

module Site2
  # Ficha técnica: una grilla de "datos" —cifra grande, etiqueta diminuta—, la
  # misma unidad de lectura que usan las cards. Un campo que la playa no cargó
  # simplemente no aparece: no se inventa un guión ni un "no especificado".
  class VehicleSpecsComponent < ApplicationComponent
    def initialize(vehicle:, columns: 3)
      @vehicle = vehicle
      @columns = columns
    end

    private

    attr_reader :vehicle

    def rows
      [
        [ t("site2.vehicles.spec_year"),         vehicle.year.to_s ],
        [ t("site2.vehicles.spec_mileage"),      mileage(vehicle.mileage) ],
        [ t("site2.vehicles.spec_transmission"), Vehicle.human_enum_name(:transmission, vehicle.transmission) ],
        [ t("site2.vehicles.spec_fuel"),         Vehicle.human_enum_name(:fuel_type, vehicle.fuel_type) ],
        [ t("site2.vehicles.spec_brand"),        vehicle.brand.name ],
        [ t("site2.vehicles.spec_model"),        vehicle.vehicle_model.name ],
        [ t("site2.vehicles.spec_category"),     vehicle.category.name ],
        [ t("site2.vehicles.spec_engine"),       vehicle.engine ],
        [ t("site2.vehicles.spec_color"),        vehicle.color ]
      ].select { |_label, value| value.present? }
    end

    # Escrito literal y no interpolado: Tailwind lee el código fuente y una
    # clase construida con string no existiría en la hoja compilada.
    def columns_class
      @columns == 2 ? "grid-cols-2" : "grid-cols-2 sm:grid-cols-3"
    end
  end
end
