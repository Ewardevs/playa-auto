# frozen_string_literal: true

module Site
  # Home hero: a full-bleed photograph with the search console docked into its
  # lower edge, so the first thing a visitor can do is look for a car.
  #
  # Every word comes from Contenido in the admin.
  class HeroComponent < ApplicationComponent
    renders_one :search

    def initialize(vehicle_count: 0)
      @vehicle_count = vehicle_count
    end

    private

    attr_reader :vehicle_count

    def content_record = site_content

    def title = content_record.hero_title.presence || t("site.home.hero_title_fallback")

    def subtitle = content_record.hero_subtitle

    def body = content_record.hero_text

    def button_label = content_record.hero_button_label.presence || t("site.cta.see_vehicles")

    def button_url = content_record.hero_button_url.presence || helpers.site_vehicles_path

    def image = content_record.hero_image

    def whatsapp_url = Vehicles::WhatsappMessage.new.link
  end
end
