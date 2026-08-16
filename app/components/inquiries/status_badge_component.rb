# frozen_string_literal: true

module Inquiries
  # Inquiry status as a telltale, matching the vehicle badges so a status reads
  # the same way everywhere in the panel.
  class StatusBadgeComponent < ApplicationComponent
    TONES = {
      "new_lead" => :accent,
      "contacted" => :info,
      "negotiating" => :warn,
      "sold" => :ok,
      "closed" => :off
    }.freeze

    def initialize(inquiry_or_status, size: :md, **options)
      @status = if inquiry_or_status.respond_to?(:status)
                  inquiry_or_status.status
      else
                  inquiry_or_status.to_s
      end
      @size    = size
      @options = options
    end

    def call
      render UI::BadgeComponent.new(
        Inquiry.human_enum_name(:status, @status),
        tone: TONES.fetch(@status, :off),
        lamp: true,
        size: @size,
        **@options
      )
    end
  end
end
