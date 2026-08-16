# frozen_string_literal: true

module Site2
  # Encabezado de sección.
  #
  # Cada sección de Site2 está numerada: el índice en naranja, el rótulo en
  # versalitas y el título en display, todo colgado de un filete que cruza el
  # ancho. Es lo que da al recorrido la sensación de catálogo ordenado en vez de
  # una sucesión de bloques.
  class SectionComponent < ApplicationComponent
    renders_one :action

    def initialize(index: nil, label: nil, title:, lead: nil, tone: :dark)
      @index = index
      @label = label
      @title = title
      @lead  = lead
      @tone  = tone
    end

    private

    attr_reader :index, :label, :title, :lead

    def title_color = @tone == :light ? "text-s2-void" : "text-s2-chalk"
    def lead_color  = @tone == :light ? "text-s2-void/60" : "text-s2-ash"
    def rule_color  = @tone == :light ? "bg-s2-void/15" : "bg-s2-line"
  end
end
