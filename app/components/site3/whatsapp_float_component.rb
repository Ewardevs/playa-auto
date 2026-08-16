# frozen_string_literal: true

module Site3
  # El canal de conversión, siempre a mano: una píldora flotante centrada abajo.
  #
  # No es un botón redondo en la esquina (Site1) ni una barra que ocupa todo el
  # ancho (Site2): es una píldora con etiqueta, que en una ficha además muestra
  # el precio. El mensaje sale de Vehicles::WhatsappMessage, así el vendedor
  # recibe un texto que ya dice de qué unidad se trata.
  class WhatsappFloatComponent < ApplicationComponent
    def initialize(vehicle: nil)
      @vehicle = vehicle
    end

    def render? = link.present?

    private

    attr_reader :vehicle

    def message = @message ||= Vehicles::WhatsappMessage.new(vehicle, setting: current_setting)

    def link = @link ||= message.link

    def vehicle? = vehicle.present?

    def track_url
      return unless vehicle?

      helpers.whatsapp_click_site3_vehicle_path(vehicle)
    end

    def track_data
      return {} unless vehicle?

      { controller: "whatsapp-track",
        whatsapp_track_url_value: track_url,
        action: "click->whatsapp-track#record" }
    end
  end
end
