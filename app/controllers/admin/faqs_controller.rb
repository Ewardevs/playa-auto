module Admin
  class FaqsController < BaseController
    before_action :set_faq, only: %i[show edit update destroy toggle]

    def index
      authorize Faq
      @pagy, @faqs = paginate(policy_scope(Faq).ordered)

      breadcrumb t("admin.content.title"), admin_content_path
      breadcrumb t("admin.faqs.title")
    end

    def show
      authorize @faq
      redirect_to edit_admin_faq_path(@faq)
    end

    def new
      @faq = Faq.new(position: (Faq.maximum(:position) || 0) + 1)
      authorize @faq
      breadcrumbs_for_form
    end

    def create
      @faq = Faq.new(permitted_attributes(Faq))
      authorize @faq

      if @faq.save
        redirect_to admin_faqs_path, notice: t("admin.faqs.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @faq
      breadcrumbs_for_form
    end

    def update
      authorize @faq

      if @faq.update(permitted_attributes(@faq))
        redirect_to admin_faqs_path, notice: t("admin.faqs.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @faq
      @faq.destroy!

      redirect_to admin_faqs_path, notice: t("admin.faqs.destroyed"), status: :see_other
    end

    def toggle
      authorize @faq, :toggle?
      @faq.toggle_active!

      notice = @faq.active? ? t("admin.faqs.activated") : t("admin.faqs.deactivated")
      redirect_back fallback_location: admin_faqs_path, notice: notice, status: :see_other
    end

    private

    def set_faq
      @faq = Faq.find(params[:id])
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.faqs.title"), admin_faqs_path
      breadcrumb @faq.persisted? ? @faq.question.truncate(40) : t("admin.faqs.new")
    end
  end
end
