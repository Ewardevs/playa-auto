# frozen_string_literal: true

module Vehicles
  # Vehicle status as an illuminated telltale, using the conventions of a real
  # dashboard: green go, amber caution, blue information, grey off.
  class StatusBadgeComponent < ApplicationComponent
    TONES = {
      "available" => :ok,
      "reserved" => :warn,
      "sold" => :info,
      "hidden" => :off
    }.freeze

    def initialize(vehicle_or_status, size: :md, **options)
      @status = if vehicle_or_status.respond_to?(:status)
                  vehicle_or_status.status
      else
                  vehicle_or_status.to_s
      end
      @size    = size
      @options = options
    end

    def call
      render UI::BadgeComponent.new(
        Vehicle.human_enum_name(:status, @status),
        tone: TONES.fetch(@status, :off),
        lamp: true,
        size: @size,
        **@options
      )
    end
  end
end
