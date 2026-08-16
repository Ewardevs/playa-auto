# frozen_string_literal: true

module Site4
  # Ruta de navegación. El último tramo es la página actual y no es un enlace.
  class BreadcrumbsComponent < ApplicationComponent
    def initialize(items:)
      @items = Array(items)
    end

    def render? = @items.any?

    private

    attr_reader :items

    def trail = [ [ t("site4.nav.home"), helpers.site4_root_path ] ] + items

    def last?(index) = index == trail.size - 1
  end
end
