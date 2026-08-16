# frozen_string_literal: true

module Site2
  # El canal de conversión, siempre a mano.
  #
  # En una ficha de vehículo el teléfono muestra una barra inferior con el
  # precio y el botón —el momento de decidir es mirando la unidad, no
  # navegando—; en el resto del sitio y en escritorio queda un botón redondo.
  # El mensaje sale de Vehicles::WhatsappMessage, así el vendedor recibe siempre
  # un texto que ya dice de qué unidad se trata.
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

      helpers.whatsapp_click_site2_vehicle_path(vehicle)
    end
  end
end
