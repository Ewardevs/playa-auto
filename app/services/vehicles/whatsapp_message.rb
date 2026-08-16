module Vehicles
  # Builds the pre-filled WhatsApp text so the seller receives a message that
  # already says which vehicle it is about.
  #
  #   "Hola, estoy interesado en el Toyota Hilux 2024 (V-00042) publicado en su
  #    web. ¿Podrían brindarme más información?"
  class WhatsappMessage
    def self.call(...) = new(...).text

    def initialize(vehicle = nil, setting: Setting.current)
      @vehicle = vehicle
      @setting = setting
    end

    def text
      @vehicle ? vehicle_message : general_message
    end

    # The full https://wa.me/… link, or nil when no number is configured.
    def link = @setting.whatsapp_link(message: text)

    private

    def vehicle_message
      I18n.t(
        "site.whatsapp.vehicle_message",
        vehicle: @vehicle.display_name,
        code: @vehicle.code,
        price: formatted_price
      )
    end

    def general_message
      I18n.t("site.whatsapp.general_message", company: @setting.company_name)
    end

    def formatted_price
      ActiveSupport::NumberHelper.number_to_delimited(
        @vehicle.current_price.to_i, delimiter: "."
      ).prepend("#{@setting.currency_symbol} ")
    end
  end
end
