# frozen_string_literal: true

module Site
  # The public enquiry form. Creates the same `Inquiry` the sales team works in
  # the panel — the enquiry a visitor sends here is the row that appears in
  # Admin → Consultas.
  #
  # Two invisible defences travel with the form: a honeypot field and the time
  # it was opened. Both are read by `Inquiries::Create`; neither bothers a
  # human.
  class InquiryFormComponent < ApplicationComponent
    def initialize(inquiry:, vehicle: nil, vehicles: [], compact: false)
      @inquiry  = inquiry
      @vehicle  = vehicle
      @vehicles = vehicles
      @compact  = compact
    end

    private

    attr_reader :inquiry, :vehicle, :vehicles

    def compact? = @compact

    # On a vehicle page the car is already known, so the picker is hidden and
    # the slug travels along.
    def vehicle_locked? = vehicle.present?

    def vehicle_options
      vehicles.map { |v| [ "#{v.display_name} — #{helpers.money(v.current_price)}", v.slug ] }
    end

    def errors_on(attribute) = inquiry.errors[attribute]

    def invalid?(attribute) = errors_on(attribute).any?

    def field_classes(attribute)
      border = invalid?(attribute) ? "border-red-500" : "border-sand focus:border-brand"

      "w-full h-11 px-3 rounded-md border bg-white text-graphite text-sm " \
        "placeholder:text-stone-2 focus:outline-none transition-colors #{border}"
    end

    def area_classes(attribute)
      field_classes(attribute).sub("h-11", "py-2.5 min-h-28")
    end

    def label_classes = "block text-[0.8125rem] font-medium text-graphite mb-1.5"
  end
end
