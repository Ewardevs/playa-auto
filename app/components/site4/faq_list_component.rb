# frozen_string_literal: true

module Site4
  # Preguntas frecuentes: cada una es un <details> nativo dentro de su propia
  # superficie. Se abre sin JavaScript, el navegador ya sabe anunciarlo a un
  # lector de pantalla y el buscador encuentra la respuesta aunque esté plegada.
  class FaqListComponent < ApplicationComponent
    def initialize(faqs:)
      @faqs = Array(faqs)
    end

    def render? = @faqs.any?

    private

    attr_reader :faqs
  end
end
