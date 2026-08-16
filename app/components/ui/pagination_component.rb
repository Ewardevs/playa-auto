# frozen_string_literal: true

module UI
  # Renders a Pagy result. The page window is computed here rather than through
  # Pagy's own nav helpers so the markup stays part of the design system, and
  # every link preserves the filters currently applied.
  class PaginationComponent < ApplicationComponent
    WINDOW = 2
    GAP = :gap

    def initialize(pagy, **options)
      @pagy    = pagy
      @options = options
    end

    def render? = @pagy.present? && @pagy.pages > 1

    private

    attr_reader :pagy

    def page  = pagy.page
    def pages = pagy.pages

    # e.g. [1, :gap, 4, 5, 6, :gap, 12]
    def series
      visible = ([ 1, pages ] + ((page - WINDOW)..(page + WINDOW)).to_a)
                  .select { |n| n.between?(1, pages) }
                  .uniq
                  .sort

      visible.each_with_object([]) do |number, list|
        list << GAP if list.any? && number - list.last.to_i > 1
        list << number
      end
    end

    def url_for_page(number)
      helpers.url_for(request.query_parameters.merge(page: number).symbolize_keys)
    end

    def link_classes(active:)
      base = "grid place-items-center min-w-8 h-8 px-2 rounded-md text-[0.8125rem] font-medium transition-colors"

      if active
        "#{base} bg-ink text-canvas"
      else
        "#{base} text-muted hover:bg-surface-3 hover:text-ink"
      end
    end

    def step_classes(enabled:)
      base = "grid place-items-center size-8 rounded-md border border-line transition-colors"

      enabled ? "#{base} text-ink hover:bg-surface-3" : "#{base} text-faint opacity-45 pointer-events-none"
    end
  end
end
