# frozen_string_literal: true

module Site
  # Vehicle photo gallery: one large frame plus thumbnails.
  #
  # Only the first photo loads eagerly; the rest are lazy, so a twenty-photo
  # listing still opens fast on a phone. Switching photos is pure CSS state
  # driven by a tiny Stimulus controller — no layout shift, no reflow.
  class VehicleGalleryComponent < ApplicationComponent
    def initialize(vehicle)
      @vehicle = vehicle
    end

    def render? = images.any?

    private

    attr_reader :vehicle

    # Main photo first, then the rest in their admin order.
    def images
      @images ||= vehicle.images.select { |image| image.file.attached? }
                         .sort_by { |image| [ image.main? ? 0 : 1, image.position, image.id ] }
    end

    def multiple? = images.size > 1

    def alt_for(image, index)
      image.alt_text.presence ||
        t("site.vehicles.photo_alt_indexed", vehicle: vehicle.display_name, index: index + 1)
    end
  end
end
