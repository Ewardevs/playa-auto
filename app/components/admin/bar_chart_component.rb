# frozen_string_literal: true

module Admin
  # Inline SVG column chart — no charting library, nothing for importmap to
  # pin, and it renders identically on first paint.
  #
  # Takes an ordered list of [label, value] pairs.
  class BarChartComponent < ApplicationComponent
    HEIGHT = 132
    GAP_RATIO = 0.34

    def initialize(series:, height: HEIGHT, format: :integer)
      @series = Array(series)
      @height = height
      @format = format
    end

    def render? = @series.any?

    private

    attr_reader :series, :height

    def values = series.map { |(_, value)| value.to_f }

    def max = [ values.max.to_f, 1.0 ].max

    def count = series.size

    # Bars are laid out in a 0..100 viewBox so the chart scales to any width.
    def slot_width = 100.0 / count

    def bar_width = slot_width * (1 - GAP_RATIO)

    def bar_x(index) = (index * slot_width) + (slot_width * GAP_RATIO / 2)

    def bar_height(value)
      return 0.0 if value.to_f <= 0

      # Floor at 2px so a non-zero month is never invisible.
      [ (value.to_f / max) * height, 2.0 ].max
    end

    def bar_y(value) = height - bar_height(value)

    def peak?(value) = value.to_f.positive? && value.to_f == values.max

    def formatted(value)
      @format == :currency ? helpers.money(value) : number_with_delimiter(value.to_i)
    end
  end
end
