# frozen_string_literal: true

module Site
  # Public navigation.
  #
  # On the home page it starts transparent over the hero photograph and turns
  # solid once the visitor scrolls past it; everywhere else it is solid from the
  # first paint. That is the only behaviour worth JavaScript here.
  class HeaderComponent < ApplicationComponent
    Link = Struct.new(:label, :path, :match, keyword_init: true)

    def initialize(current_path:, transparent: false)
      @current_path = current_path
      @transparent  = transparent
    end

    private

    attr_reader :current_path

    def transparent? = @transparent

    def links
      [
        Link.new(label: t("site.nav.vehicles"), path: helpers.site_vehicles_path, match: :prefix),
        Link.new(label: t("site.nav.offers"), path: helpers.site_offers_path, match: :prefix),
        Link.new(label: t("site.nav.about"), path: helpers.site_about_path, match: :exact),
        Link.new(label: t("site.nav.faqs"), path: helpers.site_faqs_path, match: :exact),
        Link.new(label: t("site.nav.contact"), path: helpers.site_contact_path, match: :exact)
      ]
    end

    def active?(link)
      link.match == :exact ? current_path == link.path : current_path.start_with?(link.path)
    end

    def whatsapp_url = Vehicles::WhatsappMessage.new.link

    def logo = current_setting.logo
  end
end
