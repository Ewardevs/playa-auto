# frozen_string_literal: true

module Site
  # The one vehicle card on the public site: home, catalogue, offers, search
  # results and related vehicles all render this.
  #
  # It assumes its associations are already loaded — the controller's query
  # preloads brand, model, offer and the main image, so a grid of twelve cards
  # costs no extra queries.
  class VehicleCardComponent < ApplicationComponent
    def initialize(vehicle, size: :md, eager: false)
      @vehicle = vehicle
      @size    = size
      @eager   = eager
    end

    private

    attr_reader :vehicle

    # The first row of a grid is above the fold, so those images load eagerly and
    # the rest stay lazy.
    def loading = @eager ? "eager" : "lazy"

    def fetch_priority = @eager ? "high" : "auto"

    def image = @image ||= vehicle.main_image

    def image? = image.present? && image.file.attached?

    def image_alt
      image&.alt_text.presence || t("site.vehicles.photo_alt", vehicle: vehicle.display_name)
    end

    def sold? = vehicle.sold?

    def discounted? = vehicle.discounted?

    def title = "#{vehicle.brand.name} #{vehicle.vehicle_model.name}"

    def path = helpers.site_vehicle_path(vehicle)

    def offer_ends_on = vehicle.running_offer&.ends_on
  end
end
