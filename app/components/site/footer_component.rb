# frozen_string_literal: true

module Site
  # Site footer. Every value comes from the company Setting — there is not a
  # single phone number or address written into this component.
  class FooterComponent < ApplicationComponent
    SOCIAL_ICONS = { instagram: :image, facebook: :users, tiktok: :star }.freeze

    def initialize(current_path: nil)
      @current_path = current_path
    end

    private

    def links
      [
        [ t("site.nav.home"), helpers.site_root_path ],
        [ t("site.nav.vehicles"), helpers.site_vehicles_path ],
        [ t("site.nav.offers"), helpers.site_offers_path ],
        [ t("site.nav.about"), helpers.site_about_path ],
        [ t("site.nav.faqs"), helpers.site_faqs_path ],
        [ t("site.nav.contact"), helpers.site_contact_path ]
      ]
    end

    def socials = current_setting.social_links

    def social_icon(network) = SOCIAL_ICONS.fetch(network, :external)

    def hours = current_setting.opening_hours_lines

    def whatsapp_url = Vehicles::WhatsappMessage.new.link

    def year = Date.current.year
  end
end
