# frozen_string_literal: true

module Site4
  # "Por qué comprarnos". Cada afirmación sale del modelo Differential: las
  # promesas son de la playa, no del software.
  #
  # El ícono vive en un rectángulo de esquinas suaves sobre la superficie; si el
  # ícono elegido no existe en el sistema, el rectángulo queda igual y no se
  # rompe nada.
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
