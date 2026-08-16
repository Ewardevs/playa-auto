# frozen_string_literal: true

module Site
  # FAQ list built on <details>/<summary>: open, close and keyboard support all
  # come from the browser, so this ships no JavaScript at all.
  class FaqAccordionComponent < ApplicationComponent
    def initialize(faqs:)
      @faqs = faqs
    end

    def render? = @faqs.any?

    private

    attr_reader :faqs
  end
end
