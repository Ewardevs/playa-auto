# frozen_string_literal: true

module Site3
  # Formulario de consulta.
  #
  # Crea el mismo `Inquiry` que el vendedor abre en /admin/consultas. Las
  # defensas contra spam viven en Inquiries::Create, no acá; de este lado solo
  # están sus dos entradas: el campo trampa y la marca de tiempo de apertura,
  # que el controlador Stimulus completa al conectarse.
  class InquiryFormComponent < ApplicationComponent
    def initialize(inquiry:, vehicle: nil, vehicles: [])
      @inquiry  = inquiry
      @vehicle  = vehicle
      @vehicles = Array(vehicles)
    end

    private

    attr_reader :inquiry, :vehicle, :vehicles

    def vehicle_options = vehicles.map { |record| [ record.display_name, record.slug ] }

    def selectable_vehicles? = vehicle.blank? && vehicles.any?

    def selected_vehicle_slug = helpers.params.dig(:inquiry, :vehicle_slug)

    def message_placeholder
      t("site3.inquiries.message_placeholder",
        vehicle: vehicle ? t("site3.inquiries.about_vehicle") : "")
    end

    def errors? = inquiry.errors.any?

    def error_messages = inquiry.errors.full_messages

    # Campos rellenos y redondeados sobre el lienzo: la forma en que se ven los
    # controles de una aplicación, no los de un formulario impreso.
    def field_class
      "w-full h-12 px-4 rounded-s3-sm bg-s3-canvas border-0 text-[0.9375rem] text-s3-ink " \
      "placeholder:text-s3-ink-3 focus:outline-none focus:ring-2 focus:ring-s3-accent/30 " \
      "transition-shadow"
    end

    def label_class = "s3-label block mb-2"
  end
end
