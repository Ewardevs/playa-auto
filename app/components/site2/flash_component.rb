# frozen_string_literal: true

module Site2
  # Mensajes de sistema, como una franja a ancho completo bajo el encabezado.
  # Se cierran solos con el controlador `dismiss`, que ya usa el resto de la app.
  class FlashComponent < ApplicationComponent
    # Clases escritas enteras: Tailwind lee el código fuente, y una clase armada
    # por interpolación no existiría en la hoja compilada.
    TONES = {
      "notice" => { bar: "bg-s2-mint",   text: "text-s2-mint",   icon: :check_circle },
      "alert"  => { bar: "bg-s2-signal", text: "text-s2-signal", icon: :alert }
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
