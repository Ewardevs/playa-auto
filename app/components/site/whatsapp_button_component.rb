# frozen_string_literal: true

module Site
  # WhatsApp call to action. The number and the message both come from the
  # domain — `Vehicles::WhatsappMessage` builds the text, `Setting` holds the
  # number — so neither is ever written into a view.
  #
  # When a vehicle is given, opening the chat also records the click so the
  # admin can report on the channel that actually converts.
  class WhatsappButtonComponent < ApplicationComponent
    def initialize(vehicle: nil, label: nil, variant: :whatsapp, size: :lg, full: false, **options)
      @vehicle = vehicle
      @label   = label
      @variant = variant
      @size    = size
      @full    = full
      @options = options
    end

    # Nothing to render when the playa has not configured a number.
    def render? = link.present?

    def call
      render UI::ButtonComponent.new(
        label: @label || t("site.cta.whatsapp"),
        href: link,
        variant: @variant,
        size: @size,
        full: @full,
        icon: :phone,
        target: "_blank",
        rel: "noopener",
        data: tracking_data,
        **@options
      )
    end

    private

    def message = @message ||= Vehicles::WhatsappMessage.new(@vehicle)

    def link = @link ||= message.link

    def tracking_data
      return {} if @vehicle.blank?

      {
        controller: "whatsapp-track",
        whatsapp_track_url_value: helpers.whatsapp_click_site_vehicle_path(@vehicle),
        action: "click->whatsapp-track#record"
      }
    end
  end
end
