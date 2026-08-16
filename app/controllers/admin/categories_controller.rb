module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: %i[show edit update destroy toggle]

    def index
      authorize Category
      @pagy, @categories = paginate(policy_scope(Category).search(params[:q]).order(:position, :name))

      breadcrumb t("admin.categories.title")
    end

    def show
      authorize @category
      redirect_to edit_admin_category_path(@category)
    end

    def new
      @category = Category.new
      authorize @category
      breadcrumbs_for_form
    end

    def create
      @category = Category.new(permitted_attributes(Category))
      authorize @category

      if @category.save
        redirect_to admin_categories_path, notice: t("admin.categories.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @category
      breadcrumbs_for_form
    end

    def update
      authorize @category

      if @category.update(permitted_attributes(@category))
        redirect_to admin_categories_path, notice: t("admin.categories.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @category
      @category.destroy!

      redirect_to admin_categories_path, notice: t("admin.categories.destroyed"), status: :see_other
    rescue ActiveRecord::InvalidForeignKey
      redirect_to admin_categories_path, alert: t("admin.categories.in_use"), status: :see_other
    end

    def toggle
      authorize @category, :toggle?
      @category.toggle_active!

      notice = @category.active? ? t("admin.categories.activated") : t("admin.categories.deactivated")
      redirect_back fallback_location: admin_categories_path, notice: notice, status: :see_other
    end

    private

    def set_category
      @category = Category.find_by!(slug: params[:id])
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.categories.title"), admin_categories_path
      breadcrumb @category.persisted? ? @category.name : t("admin.categories.new")
    end
  end
end
