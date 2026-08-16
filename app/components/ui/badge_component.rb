# frozen_string_literal: true

module UI
  # Small state label. With `lamp: true` it grows the illuminated telltale dot
  # used for vehicle and inquiry status across the panel.
  class BadgeComponent < ApplicationComponent
    TONES = {
      ok: { chip: "bg-ok-soft text-ok border-ok/20", lamp: "lamp-ok" },
      warn: { chip: "bg-warn-soft text-warn border-warn/20", lamp: "lamp-warn" },
      info: { chip: "bg-info-soft text-info border-info/20", lamp: "lamp-info" },
      off: { chip: "bg-off-soft text-off border-off/20", lamp: "lamp-off" },
      danger: { chip: "bg-danger-soft text-danger border-danger/20", lamp: "lamp-warn" },
      accent: { chip: "bg-accent-soft text-warn border-accent/25", lamp: "lamp-warn" },
      neutral: { chip: "bg-surface-3 text-muted border-line", lamp: "lamp-off" }
    }.freeze

    SIZES = {
      sm: "h-5 px-1.5 text-[0.6875rem] gap-1.5",
      md: "h-6 px-2 text-xs gap-1.5"
    }.freeze

    def initialize(label = nil, tone: :neutral, lamp: false, size: :md, **options)
      @label   = label
      @tone    = TONES.key?(tone) ? tone : :neutral
      @lamp    = lamp
      @size    = SIZES.key?(size) ? size : :md
      @options = options
    end

    def call
      tag.span(**@options, class: classes) do
        safe_join([ lamp_markup, tag.span(@label.presence || content) ].compact)
      end
    end

    private

    def lamp_markup
      return unless @lamp

      tag.span("", class: "lamp #{TONES[@tone][:lamp]}", aria: { hidden: true })
    end

    def classes
      class_names(
        "inline-flex items-center rounded-full border font-medium whitespace-nowrap",
        SIZES[@size],
        TONES[@tone][:chip],
        @options[:class]
      )
    end
  end
end
