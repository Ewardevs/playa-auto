# frozen_string_literal: true

module Site2
  # Pie de Site2.
  #
  # Cierra con el nombre de la empresa a tamaño de cartel, recortado por el
  # borde inferior: la última cosa que se ve es de quién es la playa. Todos los
  # datos salen de Setting — acá no hay ni un teléfono escrito a mano.
  class FooterComponent < ApplicationComponent
    Link = Struct.new(:label, :path, keyword_init: true)

    private

    def links
      @links ||= [
        Link.new(label: t("site2.nav.vehicles"), path: helpers.site2_vehicles_path),
        Link.new(label: t("site2.nav.offers"),   path: helpers.site2_offers_path),
        Link.new(label: t("site2.nav.about"),    path: helpers.site2_about_path),
        Link.new(label: t("site2.nav.faqs"),     path: helpers.site2_faqs_path),
        Link.new(label: t("site2.nav.contact"),  path: helpers.site2_contact_path)
      ]
    end

    def setting = current_setting

    def hours = setting.opening_hours_lines

    def socials = setting.social_links

    def social_label(network) = t("site2.social.#{network}", default: network.to_s.capitalize)

    def year = Date.current.year
  end
end
