# frozen_string_literal: true

module Vehicles
  # The small vehicle photo used in tables and lists. Falls back to a neutral
  # placeholder so rows never collapse when a vehicle has no photos yet.
  class ThumbnailComponent < ApplicationComponent
    SIZES = {
      sm: "w-14 h-10",
      md: "w-20 h-14",
      lg: "w-28 h-20"
    }.freeze

    def initialize(vehicle, size: :md, variant: :thumb)
      @vehicle = vehicle
      @size    = SIZES.key?(size) ? size : :md
      @variant = variant
    end

    def call
      tag.span(class: classes) { image? ? photo : placeholder }
    end

    private

    def image = @image ||= @vehicle.main_image

    def image? = image.present? && image.file.attached?

    def photo
      image_tag(image.file.variant(@variant),
                class: "size-full object-cover",
                loading: "lazy",
                alt: image.alt_text.presence || @vehicle.display_name)
    end

    def placeholder
      render UI::IconComponent.new(:car, class: "size-5 text-faint")
    end

    def classes
      class_names(
        "grid place-items-center shrink-0 overflow-hidden rounded-md bg-surface-3 border border-line",
        SIZES[@size]
      )
    end
  end
end
