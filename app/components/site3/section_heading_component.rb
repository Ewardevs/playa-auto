# frozen_string_literal: true

module Site3
  # Encabezado de sección.
  #
  # Una píldora con la etiqueta y un titular en serif de display. Sin números de
  # índice (eso es de Site2) y sin filetes ni versalitas espaciadas (eso es de
  # Site1): acá la jerarquía la da el contraste entre la píldora chiquita y el
  # titular grande.
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
