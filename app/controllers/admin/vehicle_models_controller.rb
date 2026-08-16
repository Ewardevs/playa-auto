module Admin
  class VehicleModelsController < BaseController
    before_action :set_model, only: %i[show edit update destroy toggle]

    def index
      authorize VehicleModel
      scope = policy_scope(VehicleModel).includes(:brand).search(params[:q])
      scope = scope.where(brand_id: params[:brand_id]) if params[:brand_id].present?

      @pagy, @vehicle_models = paginate(scope.joins(:brand).order("brands.name", :name))
      breadcrumb t("admin.vehicle_models.title")
    end

    # Feeds the brand → model select in the vehicle form.
    def options
      authorize VehicleModel, :index?

      models = VehicleModel.active
                           .where(brand_id: params[:brand_id])
                           .order(:name)
                           .pluck(:id, :name)
                           .map { |id, name| { id: id, name: name } }

      render json: models
    end

    def show
      authorize @vehicle_model
      redirect_to edit_admin_vehicle_model_path(@vehicle_model)
    end

    def new
      @vehicle_model = VehicleModel.new(brand_id: params[:brand_id])
      authorize @vehicle_model
      breadcrumbs_for_form
    end

    def create
      @vehicle_model = VehicleModel.new(permitted_attributes(VehicleModel))
      authorize @vehicle_model

      if @vehicle_model.save
        redirect_to admin_vehicle_models_path, notice: t("admin.vehicle_models.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @vehicle_model
      breadcrumbs_for_form
    end

    def update
      authorize @vehicle_model

      if @vehicle_model.update(permitted_attributes(@vehicle_model))
        redirect_to admin_vehicle_models_path, notice: t("admin.vehicle_models.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @vehicle_model
      @vehicle_model.destroy!

      redirect_to admin_vehicle_models_path, notice: t("admin.vehicle_models.destroyed"), status: :see_other
    rescue ActiveRecord::InvalidForeignKey
      redirect_to admin_vehicle_models_path, alert: t("admin.vehicle_models.in_use"), status: :see_other
    end

    def toggle
      authorize @vehicle_model, :toggle?
      @vehicle_model.toggle_active!

      notice = @vehicle_model.active? ? t("admin.vehicle_models.activated") : t("admin.vehicle_models.deactivated")
      redirect_back fallback_location: admin_vehicle_models_path, notice: notice, status: :see_other
    end

    private

    def set_model
      @vehicle_model = VehicleModel.find(params[:id])
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.vehicle_models.title"), admin_vehicle_models_path
      breadcrumb @vehicle_model.persisted? ? @vehicle_model.name : t("admin.vehicle_models.new")
    end
  end
end
