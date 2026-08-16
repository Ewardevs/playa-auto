# frozen_string_literal: true

module Site2
  # "Por qué comprarnos". Cada afirmación sale del modelo Differential: las
  # promesas son de la playa, no del software, y solo la playa las cambia.
  #
  # Numeradas en vez de ilustradas: el índice es la misma marca tipográfica que
  # ordena las secciones del sitio, y no depende de que exista un ícono para
  # cada concepto que a la playa se le ocurra cargar.
  class DifferentialsComponent < ApplicationComponent
    def initialize(differentials:)
      @differentials = Array(differentials)
    end

    def render? = @differentials.any?

    private

    attr_reader :differentials

    # Literales, no interpoladas: Tailwind lee el código fuente.
    def columns_class
      case differentials.size
      when 1    then "sm:grid-cols-1"
      when 2, 4 then "sm:grid-cols-2"
      else "sm:grid-cols-2 lg:grid-cols-3"
      end
    end
  end
end
