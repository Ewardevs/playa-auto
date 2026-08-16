# frozen_string_literal: true

module Site2
  # Formulario de consulta.
  #
  # Crea el mismo `Inquiry` que el vendedor abre en /admin/consultas. Las
  # defensas contra spam no viven acá sino en Inquiries::Create; de este lado
  # solo están sus dos entradas: el campo trampa y la marca de tiempo de
  # apertura, que el controlador Stimulus completa al conectarse.
  class InquiryFormComponent < ApplicationComponent
    def initialize(inquiry:, vehicle: nil, vehicles: [])
      @inquiry  = inquiry
      @vehicle  = vehicle
      @vehicles = Array(vehicles)
    end

    private

    attr_reader :inquiry, :vehicle, :vehicles

    def vehicle_options
      vehicles.map { |record| [ record.display_name, record.slug ] }
    end

    def selectable_vehicles? = vehicle.blank? && vehicles.any?

    def message_placeholder
      t("site2.inquiries.message_placeholder",
        vehicle: vehicle ? t("site2.inquiries.about_vehicle") : "")
    end

    def errors? = inquiry.errors.any?

    def error_messages = inquiry.errors.full_messages

    def selected_vehicle_slug = helpers.params.dig(:inquiry, :vehicle_slug)

    # Campo de línea, no de caja: es lo que le da al formulario el mismo aire
    # editorial que al resto del sitio.
    def field_class
      "w-full h-11 bg-transparent border-0 border-b border-s2-line text-s2-chalk " \
      "placeholder:text-s2-ash-2 text-[0.9375rem] focus:outline-none " \
      "focus:border-s2-signal transition-colors"
    end

    def label_class = "s2-stat-label block mb-1.5"
  end
end
