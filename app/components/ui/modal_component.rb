# frozen_string_literal: true

module UI
  # Native <dialog>-based modal: focus trapping, Escape to close and the
  # backdrop come from the platform instead of from JavaScript.
  #
  # The trigger slot is optional — a modal can also be opened from elsewhere by
  # dispatching `modal:open` at its id.
  class ModalComponent < ApplicationComponent
    renders_one :trigger
    renders_one :footer

    SIZES = {
      sm: "max-w-md",
      md: "max-w-lg",
      lg: "max-w-2xl",
      xl: "max-w-4xl"
    }.freeze

    def initialize(id:, title:, description: nil, size: :md)
      @id          = id
      @title       = title
      @description = description
      @size        = SIZES.key?(size) ? size : :md
    end

    private

    attr_reader :id, :title, :description

    def size_class = SIZES[@size]
  end
end
