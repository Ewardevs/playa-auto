# frozen_string_literal: true

module Vehicles
  # One photo in the gallery grid: preview, main-photo control and delete.
  # Rendered on its own so upload and reorder responses can replace a single
  # tile over Turbo Streams.
  class ImageTileComponent < ApplicationComponent
    def initialize(image:, editable: true)
      @image    = image
      @editable = editable
    end

    private

    attr_reader :image

    def editable? = @editable

    def vehicle = image.vehicle

    def main? = image.main?

    def main_path    = helpers.main_admin_vehicle_image_path(vehicle, image)
    def destroy_path = helpers.admin_vehicle_image_path(vehicle, image)
  end
end
