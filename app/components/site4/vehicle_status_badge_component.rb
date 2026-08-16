# frozen_string_literal: true

module Site4
  # Estado de la unidad. Solo aparece cuando hay algo que advertir: "disponible"
  # es la norma y no necesita etiqueta; reservado y vendido sí, siempre.
  class VehicleStatusBadgeComponent < ApplicationComponent
    TONES = {
      "reserved" => "bg-s4-amber-soft text-s4-amber",
      "sold"     => "bg-s4-ink text-white"
    }.freeze

    def initialize(vehicle)
      @vehicle = vehicle
    end

    def render? = TONES.key?(@vehicle.status)

    def call
      tag.span(Vehicle.human_enum_name(:status, @vehicle.status), class: classes)
    end

    private

    def classes
      "inline-flex items-center h-7 px-3 rounded-[0.875rem] text-[0.8125rem] font-medium " \
      "#{TONES[@vehicle.status]}"
    end
  end
end
