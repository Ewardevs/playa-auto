# frozen_string_literal: true

module UI
  # A titled block inside a long form. The vehicle form is split into these so
  # a twenty-field record still reads as a handful of decisions.
  class FormSectionComponent < ApplicationComponent
    def initialize(title:, description: nil, icon: nil, columns: 2)
      @title       = title
      @description = description
      @icon        = icon
      @columns     = columns
    end

    private

    attr_reader :title, :description, :icon

    def grid_classes
      case @columns
      when 1 then "grid gap-5"
      when 3 then "grid gap-5 sm:grid-cols-2 lg:grid-cols-3"
      else "grid gap-5 sm:grid-cols-2"
      end
    end
  end
end
