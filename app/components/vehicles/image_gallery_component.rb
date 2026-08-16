# frozen_string_literal: true

module Vehicles
  # Photo manager for a vehicle: drag-and-drop upload, reordering by dragging a
  # tile, choosing the main photo and deleting.
  #
  # Every change is a real request against a REST endpoint (create / destroy /
  # reorder / main) and comes back as a Turbo Stream, so the grid on screen and
  # the database never drift apart.
  class ImageGalleryComponent < ApplicationComponent
    def initialize(vehicle:, editable: true)
      @vehicle  = vehicle
      @editable = editable
    end

    private

    attr_reader :vehicle

    def editable? = @editable && vehicle.persisted?

    def images = @images ||= vehicle.images.to_a

    def any? = images.any?

    def upload_path  = helpers.admin_vehicle_images_path(vehicle)
    def reorder_path = helpers.reorder_admin_vehicle_images_path(vehicle)
  end
end
