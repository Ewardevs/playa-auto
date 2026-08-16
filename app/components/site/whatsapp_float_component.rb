# frozen_string_literal: true

module Site
  # Floating WhatsApp button, present on every public page.
  #
  # Sits above the fold on mobile without covering content, and stays out of the
  # way of the enquiry form's submit button.
  class WhatsappFloatComponent < ApplicationComponent
    def initialize(vehicle: nil)
      @vehicle = vehicle
    end

    def render? = link.present?

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
