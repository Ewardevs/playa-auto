# frozen_string_literal: true

module UI
  # Inline message block. Flash messages render through FlashComponent, which
  # wraps this.
  class AlertComponent < ApplicationComponent
    TONES = {
      notice: { classes: "bg-ok-soft border-ok/25 text-ok", icon: :check_circle },
      success: { classes: "bg-ok-soft border-ok/25 text-ok", icon: :check_circle },
      alert: { classes: "bg-danger-soft border-danger/25 text-danger", icon: :alert },
      error: { classes: "bg-danger-soft border-danger/25 text-danger", icon: :alert },
      warn: { classes: "bg-warn-soft border-warn/25 text-warn", icon: :alert },
      info: { classes: "bg-info-soft border-info/25 text-info", icon: :info }
    }.freeze

    def initialize(message = nil, tone: :info, title: nil, dismissible: false, **options)
      @message     = message
      @tone        = TONES.key?(tone.to_sym) ? tone.to_sym : :info
      @title       = title
      @dismissible = dismissible
      @options     = options
    end

    private

    attr_reader :title, :message, :dismissible

    def tone_classes = TONES[@tone][:classes]
    def icon         = TONES[@tone][:icon]

    def wrapper_classes
      class_names("flex items-start gap-3 rounded-md border px-4 py-3 text-sm", tone_classes, @options[:class])
    end
  end
end
