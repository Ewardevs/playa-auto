# frozen_string_literal: true

module Site4
  # Encabezado de sección.
  #
  # Micro-etiqueta editorial (punto + caja baja) y titular grande en la única
  # tipografía del sitio, con pesos extremos. Sin versalitas espaciadas (Site1),
  # sin numeral de índice (Site2) y sin píldora (Site3).
  class SectionHeadingComponent < ApplicationComponent
    renders_one :action

    def initialize(label: nil, title:, lead: nil, align: :start)
      @label = label
      @title = title
      @lead  = lead
      @align = align
    end

    private

    attr_reader :label, :title, :lead

    def centered? = @align == :center

    def wrapper_class
      centered? ? "flex flex-col items-center text-center" : "flex flex-wrap items-end justify-between gap-x-8 gap-y-5"
    end
  end
end
