# frozen_string_literal: true

module Site4
  # Mensajes de sistema, como una tarjeta suave bajo el muelle. Se cierran
  # solos con el controlador `dismiss`, que ya usa el resto de la app.
  class FlashComponent < ApplicationComponent
    # Clases escritas enteras: Tailwind lee el código fuente, y una clase armada
    # por interpolación no existiría en la hoja compilada.
    TONES = {
      "notice" => { chip: "bg-s4-accent-soft text-s4-accent", icon: :check_circle },
      "alert"  => { chip: "bg-s4-amber-soft text-s4-amber", icon: :alert }
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
