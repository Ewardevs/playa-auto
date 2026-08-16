# frozen_string_literal: true

module Site
  # Public empty state. An empty screen is an invitation to act, so it always
  # names what happened and offers the way out.
  class EmptyStateComponent < ApplicationComponent
    renders_one :action

    def initialize(title:, description: nil, icon: :search)
      @title       = title
      @description = description
      @icon        = icon
    end

    private

    attr_reader :title, :description, :icon
  end
end
