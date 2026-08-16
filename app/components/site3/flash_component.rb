# frozen_string_literal: true

module Site3
  # Mensajes de sistema, como una tarjeta flotante bajo la barra isla. Se
  # cierran solos con el controlador `dismiss`, que ya usa el resto de la app.
  class FlashComponent < ApplicationComponent
    # Clases escritas enteras: Tailwind lee el código fuente, y una clase armada
    # por interpolación no existiría en la hoja compilada.
    TONES = {
      "notice" => { chip: "bg-s3-mint-soft text-s3-mint", icon: :check_circle },
      "alert"  => { chip: "bg-s3-amber-soft text-s3-amber", icon: :alert }
    }.freeze

    def initialize(flash)
      @flash = flash
    end

    def render? = messages.any?

    private

    def messages
      @messages ||= @flash.to_h.filter_map do |type, message|
        next if message.blank?

        tone = TONES[type.to_s]
        next if tone.nil?

        [ tone, message ]
      end
    end
  end
end
