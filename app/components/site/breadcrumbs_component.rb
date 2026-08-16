# frozen_string_literal: true

module Site
  # Public breadcrumb trail. Also feeds the BreadcrumbList structured data, so
  # the path a visitor sees and the one search engines read are the same.
  class BreadcrumbsComponent < ApplicationComponent
    def initialize(crumbs:, on_night: false)
      @crumbs   = Array(crumbs)
      @on_night = on_night
    end

    def render? = @crumbs.any?

    private

    attr_reader :crumbs

    def on_night? = @on_night

    def link_classes
      on_night? ? "text-white/60 hover:text-white transition-colors" : "text-stone hover:text-graphite transition-colors"
    end

    def current_classes = on_night? ? "text-white/90" : "text-graphite"

    def separator_classes = on_night? ? "text-white/30" : "text-stone-2"
  end
end
