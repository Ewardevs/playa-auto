module Admin
  class BrandsController < BaseController
    before_action :set_brand, only: %i[show edit update destroy toggle]

    def index
      authorize Brand
      @pagy, @brands = paginate(
        policy_scope(Brand).search(params[:q]).order(:position, :name).with_attached_logo
      )

      breadcrumb t("admin.brands.title")
    end

    def show
      authorize @brand
      redirect_to edit_admin_brand_path(@brand)
    end

    def new
      @brand = Brand.new
      authorize @brand
      breadcrumbs_for_form
    end

    def create
      @brand = Brand.new(permitted_attributes(Brand))
      authorize @brand

      if @brand.save
        redirect_to admin_brands_path, notice: t("admin.brands.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @brand
      breadcrumbs_for_form
    end

    def update
      authorize @brand

      if @brand.update(permitted_attributes(@brand))
        redirect_to admin_brands_path, notice: t("admin.brands.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @brand
      @brand.destroy!

      redirect_to admin_brands_path, notice: t("admin.brands.destroyed"), status: :see_other
    rescue ActiveRecord::InvalidForeignKey
      redirect_to admin_brands_path, alert: t("admin.brands.in_use"), status: :see_other
    end

    def toggle
      authorize @brand, :toggle?
      @brand.toggle_active!

      notice = @brand.active? ? t("admin.brands.activated") : t("admin.brands.deactivated")
      redirect_back fallback_location: admin_brands_path, notice: notice, status: :see_other
    end

    private

    def set_brand
      @brand = Brand.find_by!(slug: params[:id])
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.brands.title"), admin_brands_path
      breadcrumb @brand.persisted? ? @brand.name : t("admin.brands.new")
    end
  end
end
