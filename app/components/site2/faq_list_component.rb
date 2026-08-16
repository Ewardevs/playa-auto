# frozen_string_literal: true

module Site2
  # Preguntas frecuentes.
  #
  # Cada una es un <details> nativo, igual que el panel de filtros: se abre sin
  # JavaScript, el navegador ya sabe anunciarlo a un lector de pantalla y el
  # buscador encuentra la respuesta aunque esté plegada.
  class FaqListComponent < ApplicationComponent
    def initialize(faqs:)
      @faqs = Array(faqs)
    end

    def render? = @faqs.any?

    private

    attr_reader :faqs
  end
end
