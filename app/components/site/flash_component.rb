# frozen_string_literal: true

module Site
  # Public flash messages. Announced to screen readers and dismissible, sitting
  # under the fixed header rather than over the content.
  class FlashComponent < ApplicationComponent
    TONES = {
      "notice" => { classes: "bg-brand-soft border-brand/25 text-brand-strong", icon: :check_circle },
      "alert"  => { classes: "bg-red-50 border-red-300 text-red-800", icon: :alert }
    }.freeze

    def initialize(flash)
      @flash = flash
    end

    def render? = messages.any?

    private

    def messages
      @messages ||= @flash.to_h.filter_map do |key, value|
        next if value.blank?

        [ TONES.fetch(key.to_s, TONES["notice"]), value ]
      end
    end
  end
end
