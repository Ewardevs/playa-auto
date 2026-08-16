# frozen_string_literal: true

module Site2
  # Galería de la ficha.
  #
  # No hay imagen principal ni tira de miniaturas: las fotos van una tras otra
  # en un carril horizontal con anclaje de scroll, y la posición se comunica con
  # un indicador segmentado. Se recorre con el dedo, con la rueda, con los
  # botones o con las flechas del teclado; sin JavaScript sigue siendo un carril
  # con scroll nativo, que es exactamente lo mismo menos los botones.
  class VehicleGalleryComponent < ApplicationComponent
    def initialize(vehicle:)
      @vehicle = vehicle
    end

    private

    attr_reader :vehicle

    def images
      @images ||= vehicle.images.select { |image| image.file.attached? }
    end

    def multiple? = images.size > 1

    def alt_for(index)
      return t("site2.vehicles.photo_alt", vehicle: vehicle.display_name) unless multiple?

      t("site2.vehicles.photo_alt_indexed",
        vehicle: vehicle.display_name, index: index + 1, total: images.size)
    end
  end
end
