module Site3
  # Recibe el formulario público de Site3. Crea exactamente el mismo `Inquiry`
  # que el vendedor trabaja en /admin/consultas.
  class InquiriesController < BaseController
    rate_limit to: 8, within: 5.minutes, only: :create,
               with: -> { redirect_back fallback_location: site3_contact_path,
                                        alert: t("site3.inquiries.rate_limited"), status: :see_other }

    def create
      result = Inquiries::Create.new(
        attributes: inquiry_params,
        vehicle: requested_vehicle,
        honeypot: params[:website],
        started_at: params[:form_opened_at]
      ).call

      if result.ok?
        log_outcome(result)
        redirect_to success_path, notice: t("site3.inquiries.created"), status: :see_other
      else
        render_invalid(result.inquiry)
      end
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :phone, :message)
    end

    # El vehículo llega por slug y tiene que ser públicamente visible.
    def requested_vehicle
      slug = params[:inquiry][:vehicle_slug].presence
      return if slug.blank?

      Vehicles::Public.call.find_by(slug: slug)
    end

    def success_path
      requested_vehicle ? site3_vehicle_path(requested_vehicle) : site3_contact_path
    end

    def render_invalid(inquiry)
      @inquiry = inquiry
      flash.now[:alert] = t("site3.inquiries.invalid")

      if (vehicle = requested_vehicle)
        @vehicle = Vehicles::Public.call.with_associations.find_by!(slug: vehicle.slug)
        @related = Vehicles::Related.call(@vehicle, limit: 3)
        render "site3/vehicles/show", status: :unprocessable_content
      else
        @vehicles = Vehicles::Public.call.includes(:brand, :vehicle_model)
                                    .order(:brand_id, :vehicle_model_id).limit(200)
        render "site3/pages/contact", status: :unprocessable_content
      end
    end

    def log_outcome(result)
      return if result.success?

      Rails.logger.info("[inquiry/v3] descartada por #{result.status} desde #{request.remote_ip}")
    end
  end
end
