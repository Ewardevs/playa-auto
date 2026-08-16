# frozen_string_literal: true

module Site
  # Section header used down the home page and the institutional pages:
  # a short kicker, a display title, and an optional link on the right.
  class SectionHeadingComponent < ApplicationComponent
    def initialize(title:, kicker: nil, description: nil, link_label: nil, link_path: nil, on_night: false)
      @title       = title
      @kicker      = kicker
      @description = description
      @link_label  = link_label
      @link_path   = link_path
      @on_night    = on_night
    end

    private

    attr_reader :title, :kicker, :description, :link_label, :link_path

    def on_night? = @on_night

    def title_classes
      base = "font-site-display text-2xl sm:text-3xl font-semibold tracking-tight"
      on_night? ? "#{base} text-white" : "#{base} text-graphite"
    end

    def description_classes
      on_night? ? "text-sm text-white/65 mt-2 max-w-xl" : "text-sm text-stone mt-2 max-w-xl"
    end

    def link_classes
      base = "inline-flex items-center gap-1.5 text-sm font-medium transition-colors shrink-0"
      on_night? ? "#{base} text-white/80 hover:text-white" : "#{base} text-brand hover:text-brand-strong"
    end
  end
end
