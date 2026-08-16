# frozen_string_literal: true

module Site3
  # Pie de Site3: una sola superficie oscura, redondeada, que flota sobre el
  # lienzo con aire alrededor — no una banda pegada al borde inferior de la
  # pantalla. Todos los datos salen de Setting.
  class FooterComponent < ApplicationComponent
    Link = Struct.new(:label, :path, keyword_init: true)

    private

    def links
      @links ||= [
        Link.new(label: t("site3.nav.vehicles"), path: helpers.site3_vehicles_path),
        Link.new(label: t("site3.nav.offers"),   path: helpers.site3_offers_path),
        Link.new(label: t("site3.nav.about"),    path: helpers.site3_about_path),
        Link.new(label: t("site3.nav.faqs"),     path: helpers.site3_faqs_path),
        Link.new(label: t("site3.nav.contact"),  path: helpers.site3_contact_path)
      ]
    end

    def setting = current_setting

    def hours = setting.opening_hours_lines

    def socials = setting.social_links

    def social_label(network) = t("site3.social.#{network}", default: network.to_s.capitalize)

    def year = Date.current.year
  end
end
