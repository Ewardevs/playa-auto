module Site
  # Receives the public enquiry form. Creates the very same `Inquiry` the sales
  # team works from in the panel — there is no parallel record and nothing to
  # sync afterwards.
  class InquiriesController < BaseController
    # A burst from one address is a bot, not a buyer.
    rate_limit to: 8, within: 5.minutes, only: :create,
               with: -> { redirect_back fallback_location: site_contact_path,
                                        alert: t("site.inquiries.rate_limited"), status: :see_other }

    def create
      result = Inquiries::Create.new(
        attributes: inquiry_params,
        vehicle: requested_vehicle,
        honeypot: params[:website],
        started_at: params[:form_opened_at]
      ).call

      if result.ok?
        log_outcome(result)
        redirect_to success_path, notice: t("site.inquiries.created"), status: :see_other
      else
        render_invalid(result.inquiry)
      end
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :phone, :message)
    end

    # The vehicle comes from a slug and must be publicly visible: an enquiry can
    # never be attached to hidden or archived stock.
    def requested_vehicle
      slug = params[:inquiry][:vehicle_slug].presence
      return if slug.blank?

      Vehicles::Public.call.find_by(slug: slug)
    end

    def success_path
      requested_vehicle ? site_vehicle_path(requested_vehicle) : site_contact_path
    end

    # A rejected submission is re-rendered with the visitor's text intact, on the
    # page they were already on.
    def render_invalid(inquiry)
      @inquiry = inquiry
      flash.now[:alert] = t("site.inquiries.invalid")

      if (vehicle = requested_vehicle)
        @vehicle = Vehicles::Public.call.with_associations.find_by!(slug: vehicle.slug)
        @related = Vehicles::Related.call(@vehicle, limit: 4)
        render "site/vehicles/show", status: :unprocessable_content
      else
        @vehicles = Vehicles::Public.call.with_associations.order(:brand_id).limit(200)
        render "site/pages/contact", status: :unprocessable_content
      end
    end

    def log_outcome(result)
      return if result.success?

      Rails.logger.info("[inquiry] descartada por #{result.status} desde #{request.remote_ip}")
    end
  end
end
