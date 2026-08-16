# frozen_string_literal: true

module Admin
  # Inline SVG donut for the inventory status split, drawn with stroke-dasharray
  # so there is no path maths and no dependency.
  #
  # Takes segments of [label, value, tone].
  class DonutChartComponent < ApplicationComponent
    RADIUS = 42
    STROKE = 14
    CIRCUMFERENCE = 2 * Math::PI * RADIUS

    STROKES = {
      ok: "stroke-ok",
      warn: "stroke-warn",
      info: "stroke-info",
      off: "stroke-off",
      accent: "stroke-accent"
    }.freeze

    DOTS = {
      ok: "bg-ok", warn: "bg-warn", info: "bg-info", off: "bg-off", accent: "bg-accent"
    }.freeze

    def initialize(segments:, total_label: nil)
      @segments    = Array(segments).reject { |(_, value, _)| value.to_i.zero? }
      @total_label = total_label
    end

    def render? = total.positive?

    private

    attr_reader :segments, :total_label

    def total = @total ||= segments.sum { |(_, value, _)| value.to_i }

    def radius = RADIUS
    def stroke = STROKE

    # Each segment is an arc: dash length = its share, offset = where it starts.
    def arcs
      offset = 0.0

      segments.map do |(label, value, tone)|
        share  = value.to_f / total
        length = share * CIRCUMFERENCE
        arc = {
          label: label,
          value: value.to_i,
          share: share,
          stroke_class: STROKES.fetch(tone&.to_sym, "stroke-off"),
          dot_class: DOTS.fetch(tone&.to_sym, "bg-off"),
          dasharray: "#{length} #{CIRCUMFERENCE - length}",
          dashoffset: -offset
        }
        offset += length
        arc
      end
    end

    def percentage(share) = (share * 100).round
  end
end
