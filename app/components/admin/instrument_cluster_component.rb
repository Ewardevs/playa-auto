# frozen_string_literal: true

module Admin
  # The dashboard headline, laid out as one continuous instrument panel rather
  # than a row of floating cards: hairline-divided cells, a monospaced figure,
  # and a gauge line underneath that fills in proportion to the whole fleet.
  #
  # Cells that link somewhere carry the filter that produced the number, so a
  # figure is always one click from the rows behind it.
  class InstrumentClusterComponent < ApplicationComponent
    Metric = Struct.new(:label, :value, :ratio, :tone, :href, :hint, keyword_init: true)

    TONES = {
      ink: "bg-ink",
      ok: "bg-ok",
      warn: "bg-warn",
      info: "bg-info",
      off: "bg-off",
      accent: "bg-accent"
    }.freeze

    def initialize(metrics:)
      @metrics = Array(metrics)
    end

    def render? = @metrics.any?

    private

    attr_reader :metrics

    def gauge_class(metric) = TONES.fetch(metric.tone&.to_sym, "bg-ink")

    # Guard against a zero fleet: an empty gauge, not a division error.
    def gauge_width(metric)
      ratio = metric.ratio.to_f
      return 0 unless ratio.finite? && ratio.positive?

      (ratio.clamp(0, 1) * 100).round(1)
    end

    # Spelled out in full: Tailwind scans for literal class names, so these can
    # never be built by interpolation.
    def columns_class
      case metrics.size
      when 1 then "sm:grid-cols-1"
      when 2 then "sm:grid-cols-2"
      when 3 then "sm:grid-cols-3"
      when 4 then "sm:grid-cols-2 lg:grid-cols-4"
      when 5 then "sm:grid-cols-3 lg:grid-cols-5"
      else "sm:grid-cols-3 lg:grid-cols-6"
      end
    end
  end
end
