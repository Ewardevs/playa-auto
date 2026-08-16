module Site2
  # Recibe el formulario público de Site2. Crea exactamente el mismo `Inquiry`
  # que el vendedor trabaja en /admin/consultas — no hay registro paralelo ni
  # nada que sincronizar después.
  class InquiriesController < BaseController
    # Una ráfaga desde una misma dirección es un bot, no un comprador.
    rate_limit to: 8, within: 5.minutes, only: :create,
               with: -> { redirect_back fallback_location: site2_contact_path,
                                        alert: t("site2.inquiries.rate_limited"), status: :see_other }

    def create
      result = Inquiries::Create.new(
        attributes: inquiry_params,
        vehicle: requested_vehicle,
        honeypot: params[:website],
        started_at: params[:form_opened_at]
      ).call

      if result.ok?
        log_outcome(result)
        redirect_to success_path, notice: t("site2.inquiries.created"), status: :see_other
      else
        render_invalid(result.inquiry)
      end
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :phone, :message)
    end

    # El vehículo llega por slug y tiene que ser públicamente visible: una
    # consulta no puede colgarse de una unidad oculta o archivada, ni siquiera
    # pasándole el slug a mano.
    def requested_vehicle
      slug = params[:inquiry][:vehicle_slug].presence
      return if slug.blank?

      Vehicles::Public.call.find_by(slug: slug)
    end

    def success_path
      requested_vehicle ? site2_vehicle_path(requested_vehicle) : site2_contact_path
    end

    # Un envío rechazado se vuelve a renderizar con el texto del visitante
    # intacto, en la misma página en la que estaba.
    def render_invalid(inquiry)
      @inquiry = inquiry
      flash.now[:alert] = t("site2.inquiries.invalid")

      if (vehicle = requested_vehicle)
        @vehicle = Vehicles::Public.call.with_associations.find_by!(slug: vehicle.slug)
        @related = Vehicles::Related.call(@vehicle, limit: 4)
        render "site2/vehicles/show", status: :unprocessable_content
      else
        @vehicles = Vehicles::Public.call.includes(:brand, :vehicle_model)
                                    .order(:brand_id, :vehicle_model_id).limit(200)
        render "site2/pages/contact", status: :unprocessable_content
      end
    end

    def log_outcome(result)
      return if result.success?

      Rails.logger.info("[inquiry/v2] descartada por #{result.status} desde #{request.remote_ip}")
    end
  end
end
