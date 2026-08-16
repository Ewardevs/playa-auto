# frozen_string_literal: true

module Site4
  # Pie de Site4: superficie oscura con aire alrededor, como el resto de las
  # piezas del sitio. Todos los datos salen de Setting.
  class FooterComponent < ApplicationComponent
    Link = Struct.new(:label, :path, keyword_init: true)

    private

    def links
      @links ||= [
        Link.new(label: t("site4.nav.vehicles"), path: helpers.site4_vehicles_path),
        Link.new(label: t("site4.nav.offers"),   path: helpers.site4_offers_path),
        Link.new(label: t("site4.nav.about"),    path: helpers.site4_about_path),
        Link.new(label: t("site4.nav.faqs"),     path: helpers.site4_faqs_path),
        Link.new(label: t("site4.nav.contact"),  path: helpers.site4_contact_path)
      ]
    end

    def setting = current_setting

    def hours = setting.opening_hours_lines

    def socials = setting.social_links

    def social_label(network) = t("site4.social.#{network}", default: network.to_s.capitalize)

    def year = Date.current.year
  end
end
