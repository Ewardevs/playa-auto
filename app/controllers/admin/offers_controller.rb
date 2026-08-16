module Admin
  class OffersController < BaseController
    before_action :set_offer, only: %i[show edit update destroy toggle]

    def index
      authorize Offer
      # The thumbnail per row needs the image attachment preloaded too.
      scope = policy_scope(Offer).includes(
        vehicle: [ :brand, :vehicle_model, { images: { file_attachment: { blob: :variant_records } } } ]
      )
      scope = scope.where(active: params[:active] == "1") if params[:active].present?

      @pagy, @offers = paginate(scope.order(starts_on: :desc))
      breadcrumb t("admin.offers.title")
    end

    def show
      authorize @offer
      redirect_to edit_admin_offer_path(@offer)
    end

    def new
      # `previous_price` no se asigna acá: lo copia el modelo desde el precio de
      # lista del vehículo al guardar.
      @offer = Offer.new(
        vehicle_id: params[:vehicle_id],
        starts_on: Date.current,
        ends_on: 30.days.from_now.to_date
      )
      authorize @offer
      breadcrumbs_for_form
    end

    def create
      @offer = Offer.new(permitted_attributes(Offer))
      authorize @offer

      if @offer.save
        redirect_to admin_offers_path, notice: t("admin.offers.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @offer
      breadcrumbs_for_form
    end

    def update
      authorize @offer

      if @offer.update(permitted_attributes(@offer))
        redirect_to admin_offers_path, notice: t("admin.offers.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @offer
      @offer.destroy!

      redirect_to admin_offers_path, notice: t("admin.offers.destroyed"), status: :see_other
    end

    def toggle
      authorize @offer, :toggle?
      @offer.update!(active: !@offer.active)

      notice = @offer.active? ? t("admin.offers.activated") : t("admin.offers.deactivated")
      redirect_back fallback_location: admin_offers_path, notice: notice, status: :see_other
    end

    private

    def set_offer
      @offer = Offer.find(params[:id])
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.offers.title"), admin_offers_path
      breadcrumb @offer.persisted? ? @offer.display_name : t("admin.offers.new")
    end
  end
end
