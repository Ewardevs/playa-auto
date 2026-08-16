# frozen_string_literal: true

module Site
  # Catalogue filters. One form, rendered as a sidebar on desktop and as a
  # bottom drawer on mobile — the same markup, so a filter can never work in one
  # place and not the other.
  #
  # Plain GET, so filters live in the URL and a search can be shared.
  class VehicleFiltersComponent < ApplicationComponent
    def initialize(search:, brands:, categories:, models:, params: {})
      @search     = search
      @brands     = brands
      @categories = categories
      @models     = models
      @params     = params
    end

    private

    attr_reader :search, :brands, :categories, :models, :params

    def brand_options    = brands.map { |b| [ b.name, b.slug ] }
    def category_options = categories.map { |c| [ c.name, c.slug ] }
    def model_options    = models.map { |m| [ m.name, m.slug ] }

    def fuel_options
      Vehicle.fuel_types.keys.map { |value| [ Vehicle.human_enum_name(:fuel_type, value), value ] }
    end

    def transmission_options
      Vehicle.transmissions.keys.map { |value| [ Vehicle.human_enum_name(:transmission, value), value ] }
    end

    # Only the statuses the public scope already allows.
    def status_options
      Vehicles::Public.new.visible_statuses.map { |value| [ Vehicle.human_enum_name(:status, value), value ] }
    end

    def filtered? = search.filtered?

    def field_classes
      "w-full h-10 px-3 rounded-md border border-sand bg-white text-graphite text-sm " \
        "placeholder:text-stone-2 focus:border-brand focus:outline-none transition-colors"
    end

    def label_classes = "block text-[0.6875rem] font-semibold uppercase tracking-wide text-stone mb-1.5"

    def group_classes = "py-4 border-b border-sand last:border-0"

    # Sorting lives outside the drawer, so keep it when the form submits.
    def preserved_sort = params[:orden]
  end
end
