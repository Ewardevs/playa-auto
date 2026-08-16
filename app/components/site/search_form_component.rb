# frozen_string_literal: true

module Site
  # The search console on the home page. A plain GET form to /vehiculos, so a
  # search is a shareable URL and the back button behaves.
  class SearchFormComponent < ApplicationComponent
    def initialize(brands:, categories:, params: {})
      @brands     = brands
      @categories = categories
      @params     = params
    end

    private

    attr_reader :brands, :categories, :params

    def brand_options    = brands.map { |brand| [ brand.name, brand.slug ] }
    def category_options = categories.map { |category| [ category.name, category.slug ] }

    def field_classes
      "w-full h-11 px-3 rounded-md border border-sand bg-white text-graphite text-sm " \
        "placeholder:text-stone-2 focus:border-brand focus:outline-none transition-colors"
    end

    def label_classes = "block text-[0.6875rem] font-semibold uppercase tracking-wide text-stone mb-1.5"
  end
end
