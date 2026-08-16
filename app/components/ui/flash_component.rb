# frozen_string_literal: true

module UI
  # Renders the controller's flash as stacked, dismissible toasts.
  class FlashComponent < ApplicationComponent
    TONES = { "notice" => :notice, "alert" => :alert, "warn" => :warn, "info" => :info }.freeze

    def initialize(flash)
      @flash = flash
    end

    def render? = messages.any?

    private

    def messages
      @messages ||= @flash.to_h.filter_map do |key, value|
        next if value.blank?

        [ TONES.fetch(key.to_s, :info), value ]
      end
    end
  end
end
