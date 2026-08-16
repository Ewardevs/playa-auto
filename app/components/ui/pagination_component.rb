# frozen_string_literal: true

module UI
  # Renders a Pagy result. The page window is computed here rather than through
  # Pagy's own nav helpers so the markup stays part of the design system, and
  # every link preserves the filters currently applied.
  class PaginationComponent < ApplicationComponent
    WINDOW = 2
    GAP = :gap

    # One component, two skins: the pagination *logic* (the page window) is the
    # valuable part and is not worth duplicating for the public site.
    THEMES = {
      admin: {
        wrapper: "px-5 py-3 border-t border-line",
        summary: "text-xs text-muted num",
        active: "bg-ink text-canvas",
        idle: "text-muted hover:bg-surface-3 hover:text-ink",
        step: "border-line text-ink hover:bg-surface-3",
        step_off: "border-line text-faint",
        gap: "text-faint"
      },
      site: {
        wrapper: "px-1 py-6 border-t border-sand mt-8",
        summary: "text-xs text-stone font-mono",
        active: "bg-brand text-white",
        idle: "text-stone hover:bg-paper-2 hover:text-graphite",
        step: "border-sand text-graphite hover:bg-paper-2",
        step_off: "border-sand text-stone-2",
        gap: "text-stone-2"
      },
      # Site2. Se agrega una piel más y no se toca ninguna de las anteriores: el
      # cálculo de la ventana de páginas es lo valioso de este componente y no
      # vale la pena tener dos copias.
      site2: {
        wrapper: "px-1 py-8 border-t border-s2-line mt-12",
        summary: "text-[0.6875rem] uppercase tracking-[0.12em] text-s2-ash-2 tabular-nums",
        active: "bg-s2-signal text-s2-signal-ink",
        idle: "text-s2-ash hover:bg-s2-panel hover:text-s2-chalk",
        step: "border-s2-line text-s2-chalk hover:border-s2-ash-2",
        step_off: "border-s2-line text-s2-ash-2",
        gap: "text-s2-ash-2"
      },
      # Site3. Otra piel más; las tres anteriores quedan intactas.
      site3: {
        wrapper: "px-1 py-8 mt-10",
        summary: "text-[0.8125rem] text-s3-ink-3 tabular-nums",
        active: "bg-s3-accent text-white",
        idle: "text-s3-ink-2 hover:bg-s3-surface hover:text-s3-ink",
        step: "border-transparent bg-s3-surface text-s3-ink hover:bg-s3-accent-soft",
        step_off: "border-transparent bg-s3-surface text-s3-ink-3",
        gap: "text-s3-ink-3"
      }
    }.freeze

    def initialize(pagy, theme: :admin, **options)
      @pagy    = pagy
      @theme   = THEMES.key?(theme) ? theme : :admin
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

    def skin = THEMES[@theme]

    def link_classes(active:)
      base = "grid place-items-center min-w-8 h-8 px-2 rounded-md text-[0.8125rem] font-medium transition-colors"

      "#{base} #{active ? skin[:active] : skin[:idle]}"
    end

    def step_classes(enabled:)
      base = "grid place-items-center size-8 rounded-md border transition-colors"

      enabled ? "#{base} #{skin[:step]}" : "#{base} #{skin[:step_off]} opacity-45 pointer-events-none"
    end
  end
end
