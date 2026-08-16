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

    # El destino del botón se carga en el panel como un path ("/vehiculos"), y
    # ese path significa "el catálogo" de este sitio — no el de otro. Una URL
    # absoluta (una campaña, un sitio externo) se respeta tal cual, y un path
    # que no reconocemos también: no es asunto nuestro reescribirlo.
    LOCAL_EQUIVALENTS = {
      "/" => :site_root_path,
      "/vehiculos" => :site_vehicles_path,
      "/ofertas" => :site_offers_path,
      "/nosotros" => :site_about_path,
      "/preguntas-frecuentes" => :site_faqs_path,
      "/contacto" => :site_contact_path
    }.freeze

    def button_url
      configured = content_record.hero_button_url.presence
      return helpers.site_vehicles_path if configured.blank?

      helper = LOCAL_EQUIVALENTS[configured.split("?").first.chomp("/").presence || "/"]
      helper ? helpers.public_send(helper) : configured
    end

    def image = content_record.hero_image

    def whatsapp_url = Vehicles::WhatsappMessage.new.link
  end
end
