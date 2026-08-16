# frozen_string_literal: true

module Site3
  # Galería en mosaico.
  #
  # Una foto grande y hasta cuatro chicas alrededor, todas visibles a la vez y
  # sin un solo byte de JavaScript. Los otros dos sitios resuelven esto con
  # navegación —miniaturas en uno, carrusel con anclaje en el otro—; acá no hay
  # nada que navegar: la unidad se ve entera de un vistazo.
  class VehicleGalleryComponent < ApplicationComponent
    SHOWN = 5

    def initialize(vehicle:)
      @vehicle = vehicle
    end

    private

    attr_reader :vehicle

    def images
      @images ||= vehicle.images.select { |image| image.file.attached? }
    end

    def shown = images.first(SHOWN)

    def remaining = images.size - shown.size

    def alt_for(index)
      return t("site3.vehicles.photo_alt", vehicle: vehicle.display_name) if images.one?

      t("site3.vehicles.photo_alt_indexed",
        vehicle: vehicle.display_name, index: index + 1, total: images.size)
    end

    # Escritas enteras porque Tailwind lee el código fuente: una clase armada
    # por interpolación no existiría en la hoja compilada.
    #
    # En el teléfono son dos columnas y la principal ocupa las dos; en pantalla
    # ancha son cuatro columnas por dos filas y la principal ocupa un cuadrante
    # entero.
    def grid_class
      if images.one?
        "grid grid-cols-1"
      else
        "grid grid-cols-2 sm:grid-cols-4 sm:grid-rows-2 sm:h-[26rem] lg:h-[32rem]"
      end
    end

    def main_class
      if images.one?
        "aspect-16/9"
      else
        "col-span-2 sm:row-span-2 aspect-4/3 sm:aspect-auto sm:h-full"
      end
    end

    def secondary_class = "aspect-4/3 sm:aspect-auto sm:h-full"
  end
end
