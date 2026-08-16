# frozen_string_literal: true

module Site4
  # Galería de la ficha.
  #
  # Una foto principal grande, un carril de miniaturas vertical (horizontal en
  # móvil) y un visor a pantalla completa que arma el controlador Stimulus: el
  # botón que lo abre solo aparece cuando JavaScript está encendido, porque sin
  # él las miniaturas ya muestran todas las fotos.
  class VehicleGalleryComponent < ApplicationComponent
    def initialize(vehicle:)
      @vehicle = vehicle
    end

    private

    attr_reader :vehicle

    def images = @images ||= vehicle.images.select { |image| image.file.attached? }

    def image? = images.any?

    def poster
      return unless image?

      images.first.file.variant(:large)
    end

    def poster_alt = t("site4.vehicles.photo_alt", vehicle: vehicle.display_name)

    def thumb_variant(image) = image.file.variant(:card)

    def slide_variant(image) = image.file.variant(:large)

    def indexed_alt(image, index)
      t("site4.vehicles.photo_alt_indexed", vehicle: vehicle.display_name, index: index + 1, total: images.size)
    end
  end
end
