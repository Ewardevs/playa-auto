# frozen_string_literal: true

module Site3
  # Barra isla.
  #
  # No ocupa el ancho de la pantalla ni se apoya en un borde: es una píldora
  # que flota sobre el contenido, centrada, con sombra en capas. Los otros dos
  # sitios usan barras de ancho completo —una que se vuelve sólida al bajar, la
  # otra siempre sólida—; ésta nunca toca los bordes.
  class HeaderComponent < ApplicationComponent
    Link = Struct.new(:label, :path, :match, keyword_init: true)

    def initialize(current_path:, preview: false)
      @current_path = current_path.to_s
      @preview      = preview
    end

    private

    attr_reader :current_path

    def preview? = @preview

    def links
      @links ||= [
        Link.new(label: t("site3.nav.vehicles"), path: helpers.site3_vehicles_path, match: %r{\A/v3/vehiculos}),
        Link.new(label: t("site3.nav.offers"),   path: helpers.site3_offers_path,   match: %r{\A/v3/ofertas}),
        Link.new(label: t("site3.nav.about"),    path: helpers.site3_about_path,    match: %r{\A/v3/nosotros}),
        Link.new(label: t("site3.nav.faqs"),     path: helpers.site3_faqs_path,     match: %r{\A/v3/preguntas}),
        Link.new(label: t("site3.nav.contact"),  path: helpers.site3_contact_path,  match: %r{\A/v3/contacto})
      ]
    end

    def active?(link) = current_path.match?(link.match)

    def logo = current_setting.logo

    def whatsapp_url = Vehicles::WhatsappMessage.new(setting: current_setting).link
  end
end
