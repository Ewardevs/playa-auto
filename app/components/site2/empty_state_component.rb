# frozen_string_literal: true

module Site2
  # Estado vacío.
  #
  # Nunca es un callejón sin salida: siempre ofrece al menos una acción, porque
  # una búsqueda sin resultados es el momento en que más fácil se pierde a un
  # comprador.
  class EmptyStateComponent < ApplicationComponent
    renders_many :actions

    def initialize(title:, description: nil)
      @title       = title
      @description = description
    end

    private

    attr_reader :title, :description
  end
end
