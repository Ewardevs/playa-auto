module Admin
  class DifferentialsController < BaseController
    before_action :set_differential, only: %i[show edit update destroy toggle]

    def index
      authorize Differential
      @pagy, @differentials = paginate(policy_scope(Differential).ordered)

      breadcrumb t("admin.content.title"), admin_content_path
      breadcrumb t("admin.differentials.title")
    end

    def show
      authorize @differential
      redirect_to edit_admin_differential_path(@differential)
    end

    def new
      @differential = Differential.new
      authorize @differential
      breadcrumbs_for_form
    end

    def create
      @differential = Differential.new(permitted_attributes(Differential))
      authorize @differential

      if @differential.save
        redirect_to admin_differentials_path, notice: t("admin.differentials.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @differential
      breadcrumbs_for_form
    end

    def update
      authorize @differential

      if @differential.update(permitted_attributes(@differential))
        redirect_to admin_differentials_path, notice: t("admin.differentials.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @differential
      @differential.destroy!

      redirect_to admin_differentials_path, notice: t("admin.differentials.destroyed"), status: :see_other
    end

    def toggle
      authorize @differential, :toggle?
      @differential.toggle_active!

      notice = @differential.active? ? t("admin.differentials.activated") : t("admin.differentials.deactivated")
      redirect_back fallback_location: admin_differentials_path, notice: notice, status: :see_other
    end

    private

    def set_differential
      @differential = Differential.find(params[:id])
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.differentials.title"), admin_differentials_path
      breadcrumb @differential.persisted? ? @differential.title : t("admin.differentials.new")
    end
  end
end
