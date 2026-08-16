# frozen_string_literal: true

module Site4
  # Estado vacío. Nunca es un callejón sin salida: siempre ofrece al menos una
  # acción, porque una búsqueda sin resultados es donde más fácil se pierde a un
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
