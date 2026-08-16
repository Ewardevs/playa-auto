# frozen_string_literal: true

module UI
  # Active / inactive state for the catalogue entities. A separate component
  # from the status telltales because this is a two-state switch, not a
  # pipeline position.
  class StateBadgeComponent < ApplicationComponent
    def initialize(active, size: :md)
      @active = active
      @size   = size
    end

    def call
      render UI::BadgeComponent.new(
        @active ? t("admin.states.active") : t("admin.states.inactive"),
        tone: @active ? :ok : :off,
        lamp: true,
        size: @size
      )
    end
  end
end
