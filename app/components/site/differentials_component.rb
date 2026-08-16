# frozen_string_literal: true

module Site
  # "Por qué comprarnos" strip. Every claim comes from the Differential model,
  # so the playa states its own selling points and the software makes none up.
  class DifferentialsComponent < ApplicationComponent
    def initialize(differentials:, on_night: false)
      @differentials = differentials
      @on_night      = on_night
    end

    def render? = @differentials.any?

    private

    attr_reader :differentials

    def on_night? = @on_night

    def columns_class
      case differentials.size
      when 1 then "sm:grid-cols-1"
      when 2 then "sm:grid-cols-2"
      when 3 then "sm:grid-cols-3"
      when 5 then "sm:grid-cols-2 lg:grid-cols-5"
      else "sm:grid-cols-2 lg:grid-cols-4"
      end
    end

    def icon_classes
      on_night? ? "bg-white/10 text-white" : "bg-brand-soft text-brand"
    end

    def title_classes = on_night? ? "text-white" : "text-graphite"

    def body_classes = on_night? ? "text-white/60" : "text-stone"
  end
end
