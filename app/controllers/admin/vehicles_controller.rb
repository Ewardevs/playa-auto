module Admin
  class VehiclesController < BaseController
    before_action :set_vehicle, only: %i[show edit update destroy status duplicate archive restore]

    def index
      authorize Vehicle
      scope = policy_scope(Vehicle)

      @search   = Vehicles::Search.new(scope: scope, params: params)
      @pagy, @vehicles = paginate(@search.results.with_associations)

      @counts = status_counts(scope)
      breadcrumb t("admin.vehicles.title")
    end

    def show
      authorize @vehicle
      breadcrumb t("admin.vehicles.title"), admin_vehicles_path
      breadcrumb @vehicle.display_name
    end

    def new
      @vehicle = Vehicle.new(status: :available, year: Date.current.year, published_at: Time.current)
      authorize @vehicle

      breadcrumb t("admin.vehicles.title"), admin_vehicles_path
      breadcrumb t("admin.vehicles.new")
    end

    def create
      @vehicle = Vehicle.new(permitted_attributes(Vehicle))
      @vehicle.user = current_user
      authorize @vehicle

      if @vehicle.save
        redirect_to edit_admin_vehicle_path(@vehicle),
                    notice: t("admin.vehicles.created"), status: :see_other
      else
        breadcrumb t("admin.vehicles.title"), admin_vehicles_path
        breadcrumb t("admin.vehicles.new")
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @vehicle
      breadcrumb t("admin.vehicles.title"), admin_vehicles_path
      breadcrumb @vehicle.display_name, admin_vehicle_path(@vehicle)
      breadcrumb t("admin.actions.edit")
    end

    def update
      authorize @vehicle

      if @vehicle.update(permitted_attributes(@vehicle))
        redirect_to admin_vehicle_path(@vehicle), notice: t("admin.vehicles.updated"), status: :see_other
      else
        breadcrumb t("admin.vehicles.title"), admin_vehicles_path
        breadcrumb @vehicle.display_name, admin_vehicle_path(@vehicle)
        breadcrumb t("admin.actions.edit")
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @vehicle
      @vehicle.destroy!

      redirect_to admin_vehicles_path, notice: t("admin.vehicles.destroyed"), status: :see_other
    end

    # Soft delete: the vehicle leaves the inventory but the record survives.
    def archive
      authorize @vehicle, :archive?
      @vehicle.discard!

      redirect_back fallback_location: admin_vehicles_path,
                    notice: t("admin.vehicles.archived"), status: :see_other
    end

    def restore
      authorize @vehicle, :restore?
      @vehicle.undiscard!

      redirect_back fallback_location: admin_vehicles_path(archived: 1),
                    notice: t("admin.vehicles.restored"), status: :see_other
    end

    def duplicate
      authorize @vehicle, :duplicate?
      copy = Vehicles::Duplicate.new(@vehicle, user: current_user).call

      redirect_to edit_admin_vehicle_path(copy), notice: t("admin.vehicles.duplicated"), status: :see_other
    end

    def status
      authorize @vehicle, :status?

      Vehicles::ChangeStatus.new(@vehicle, status: params[:status]).call
      notice = t("admin.vehicles.status_changed", status: Vehicle.human_enum_name(:status, @vehicle.status))

      redirect_back fallback_location: admin_vehicle_path(@vehicle), notice: notice, status: :see_other
    rescue Vehicles::ChangeStatus::InvalidStatus
      redirect_back fallback_location: admin_vehicles_path,
                    alert: t("admin.errors.generic"), status: :see_other
    end

    private

    # Archived vehicles stay reachable here so they can be reviewed and restored;
    # the archived filter lives in the query object, not in a default scope.
    #
    # The screens that render the photo gallery preload it — without that, every
    # thumbnail costs its own attachment and blob query.
    def set_vehicle
      scope = renders_gallery? ? Vehicle.with_associations : Vehicle.all
      @vehicle = scope.find_by!(slug: params[:id])
    end

    def renders_gallery? = action_name.in?(%w[show edit update])

    # One grouped query behind the filter chips, rather than a COUNT per chip.
    def status_counts(scope)
      base = Vehicles::Search.new(scope: scope, params: params.except(:status, :featured, :offer, :page)).results

      {
        total: base.count,
        featured: base.featured.count,
        not_featured: base.where(featured: false).count,
        on_offer: base.offered.count,
        archived: policy_scope(Vehicle).discarded.count
      }
    end
  end
end
