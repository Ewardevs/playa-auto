# frozen_string_literal: true

module Site
  # The data plate: year · mileage · gearbox · fuel, set in monospace and
  # separated by hairlines.
  #
  # It is the site's recurring motif — identical on cards, on the detail page
  # and in search results — so a buyer always compares the same four numbers in
  # the same place, in the same shape.
  class VehicleSpecsComponent < ApplicationComponent
    def initialize(vehicle, extended: false, **options)
      @vehicle  = vehicle
      @extended = extended
      @options  = options
    end

    def call
      tag.div(class: class_names("spec-strip", @options[:class])) do
        safe_join(entries.map { |value| tag.span(value) })
      end
    end

    private

    attr_reader :vehicle

    def entries
      values = [
        vehicle.year,
        helpers.mileage(vehicle.mileage),
        Vehicle.human_enum_name(:transmission, vehicle.transmission),
        Vehicle.human_enum_name(:fuel_type, vehicle.fuel_type)
      ]

      values += [ vehicle.engine, vehicle.color ] if @extended

      values.compact_blank
    end
  end
end
