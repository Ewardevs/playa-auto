# frozen_string_literal: true

module Site2
  # Barra superior de Site2.
  #
  # A diferencia del sitio anterior, nunca es transparente y nunca cambia de
  # color: es una barra sólida y fija que *se encoge* al bajar y lleva un hilo
  # de progreso de lectura. La orientación se da con geometría, no con opacidad,
  # que es lo que la vuelve legible sobre cualquier fotografía.
  class HeaderComponent < ApplicationComponent
    Link = Struct.new(:label, :path, :match, keyword_init: true)

    def initialize(current_path:)
      @current_path = current_path.to_s
    end

    private

    attr_reader :current_path

    def links
      @links ||= [
        Link.new(label: t("site2.nav.vehicles"), path: helpers.site2_vehicles_path, match: %r{\A/v2/vehiculos}),
        Link.new(label: t("site2.nav.offers"),   path: helpers.site2_offers_path,   match: %r{\A/v2/ofertas}),
        Link.new(label: t("site2.nav.about"),    path: helpers.site2_about_path,    match: %r{\A/v2/nosotros}),
        Link.new(label: t("site2.nav.faqs"),     path: helpers.site2_faqs_path,     match: %r{\A/v2/preguntas}),
        Link.new(label: t("site2.nav.contact"),  path: helpers.site2_contact_path,  match: %r{\A/v2/contacto})
      ]
    end

    def active?(link) = current_path.match?(link.match)

    def logo = current_setting.logo

    def whatsapp_url = Vehicles::WhatsappMessage.new(setting: current_setting).link
  end
end
