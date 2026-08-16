# frozen_string_literal: true

module Site4
  # Paginación de Site4.
  #
  # Componente propio y autocontenido: la ventana de páginas es la misma lógica
  # que UI::PaginationComponent, pero acá se usa con la piel s4 y las cadenas de
  # su propio locale. No se le agrega una piel más al componente compartido para
  # no tocar nada de `UI::*`; el costo es una copia del cálculo de la ventana.
  class PaginationComponent < ApplicationComponent
    WINDOW = 2
    GAP = :gap

    def initialize(pagy:)
      @pagy = pagy
    end

    def render? = @pagy.present? && @pagy.pages > 1

    private

    attr_reader :pagy

    def page = pagy.page

    def pages = pagy.pages

    # p. ej. [1, :gap, 4, 5, 6, :gap, 12]
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
      base = "grid place-items-center min-w-9 h-9 px-2.5 rounded-[0.875rem] " \
             "text-[0.8125rem] font-medium transition-colors"

      if active
        "#{base} bg-s4-accent text-white"
      else
        "#{base} text-s4-ink-2 hover:bg-s4-canvas hover:text-s4-ink"
      end
    end

    def step_classes(enabled:)
      base = "grid place-items-center size-9 rounded-[0.875rem] border transition-colors"

      if enabled
        "#{base} border-[color:rgba(17,19,21,0.08)] bg-s4-surface text-s4-ink hover:bg-s4-canvas"
      else
        "#{base} border-[color:rgba(17,19,21,0.08)] text-s4-ink-3 opacity-45 pointer-events-none"
      end
    end
  end
end
