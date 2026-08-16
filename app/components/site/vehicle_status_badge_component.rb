# frozen_string_literal: true

module Site
  # Public status label. Only three states ever reach a visitor — available,
  # reserved and sold — because hidden and archived stock never leaves the panel.
  #
  # Colour is never the only signal: each state also carries its own word.
  class VehicleStatusBadgeComponent < ApplicationComponent
    TONES = {
      "available" => "bg-brand text-white",
      "reserved" => "bg-gold text-white",
      "sold" => "bg-graphite text-white"
    }.freeze

    SIZES = {
      sm: "h-6 px-2 text-[0.6875rem]",
      md: "h-7 px-2.5 text-xs"
    }.freeze

    def initialize(vehicle, size: :md, **options)
      @status  = vehicle.respond_to?(:status) ? vehicle.status : vehicle.to_s
      @size    = SIZES.key?(size) ? size : :md
      @options = options
    end

    # Available is the default expectation; showing a badge for it on every card
    # would be noise. Only the states that change the buyer's decision show.
    def render? = @status.in?(%w[reserved sold])

    def call
      tag.span(
        Vehicle.human_enum_name(:status, @status),
        class: class_names(
          "inline-flex items-center rounded-full font-semibold uppercase tracking-wide whitespace-nowrap",
          SIZES[@size], TONES.fetch(@status, "bg-graphite text-white"), @options[:class]
        )
      )
    end
  end
end
