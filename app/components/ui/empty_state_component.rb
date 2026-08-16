# frozen_string_literal: true

module UI
  # Empty screens are an invitation to act: they name what is missing and offer
  # the action that fixes it.
  class EmptyStateComponent < ApplicationComponent
    renders_one :action

    def initialize(title:, description: nil, icon: :inbox, compact: false)
      @title       = title
      @description = description
      @icon        = icon
      @compact     = compact
    end

    private

    attr_reader :title, :description, :icon

    def padding = @compact ? "py-8" : "py-14"
  end
end
