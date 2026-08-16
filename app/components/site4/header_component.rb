# frozen_string_literal: true

module Site4
  # El muelle adaptable.
  #
  # Ni la barra de ancho completo de los sitios anteriores ni la isla flotante
  # de Site3: es un muelle que ocupa casi todo el ancho, transparente arriba y
  # sólido al bajar (el controlador Stimulus agrega `is-solid`). El contenido
  # asoma por debajo mientras es transparente, como en una doble página.
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
        Link.new(label: t("site4.nav.vehicles"), path: helpers.site4_vehicles_path, match: %r{\A/v4/vehiculos}),
        Link.new(label: t("site4.nav.offers"),   path: helpers.site4_offers_path,   match: %r{\A/v4/ofertas}),
        Link.new(label: t("site4.nav.about"),    path: helpers.site4_about_path,    match: %r{\A/v4/nosotros}),
        Link.new(label: t("site4.nav.faqs"),     path: helpers.site4_faqs_path,     match: %r{\A/v4/preguntas}),
        Link.new(label: t("site4.nav.contact"),  path: helpers.site4_contact_path,  match: %r{\A/v4/contacto})
      ]
    end

    def active?(link) = current_path.match?(link.match)

    def logo = current_setting.logo

    def whatsapp_url = Vehicles::WhatsappMessage.new(setting: current_setting).link
  end
end
