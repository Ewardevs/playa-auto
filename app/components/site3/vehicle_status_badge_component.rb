# frozen_string_literal: true

module Site3
  # Estado de la unidad. Solo aparece cuando hay algo que advertir: "disponible"
  # es la norma y no necesita etiqueta; reservado y vendido sí, siempre.
  class VehicleStatusBadgeComponent < ApplicationComponent
    TONES = {
      "reserved" => "bg-s3-amber-soft text-s3-amber",
      "sold"     => "bg-s3-ink text-white"
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
      "inline-flex items-center h-7 px-3 rounded-full text-[0.8125rem] font-medium " \
      "#{TONES[@vehicle.status]}"
    end
  end
end
