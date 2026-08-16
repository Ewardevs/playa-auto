# frozen_string_literal: true

module Site2
  # Estado de la unidad sobre la fotografía.
  #
  # Solo aparece cuando hay algo que advertir: "disponible" es la norma y no
  # necesita etiqueta. Reservado y vendido sí, y siempre — un vendido que no se
  # anuncia como tal es una promesa que la playa no puede cumplir.
  class VehicleStatusBadgeComponent < ApplicationComponent
    TONES = {
      "reserved" => "bg-s2-amber text-s2-void",
      "sold"     => "bg-s2-ash-2 text-s2-chalk"
    }.freeze

    def initialize(vehicle)
      @vehicle = vehicle
    end

    def render? = TONES.key?(@vehicle.status)

    def call
      tag.span(label, class: classes)
    end

    private

    def label = Vehicle.human_enum_name(:status, @vehicle.status)

    def classes
      "inline-flex items-center h-6 px-2 rounded-s2 text-[0.6875rem] font-semibold " \
      "uppercase tracking-[0.08em] #{TONES[@vehicle.status]}"
    end
  end
end
