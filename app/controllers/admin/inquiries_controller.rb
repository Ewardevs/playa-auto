module Admin
  class InquiriesController < BaseController
    before_action :set_inquiry, only: %i[show edit update destroy status]

    def index
      authorize Inquiry
      scope = policy_scope(Inquiry).includes(:user, vehicle: %i[brand vehicle_model])

      @filter = Inquiries::Filter.new(scope: scope, params: params)
      @pagy, @inquiries = paginate(@filter.results)
      @status_counts = policy_scope(Inquiry).group(:status).count

      breadcrumb t("admin.inquiries.title")
    end

    def show
      authorize @inquiry
      breadcrumb t("admin.inquiries.title"), admin_inquiries_path
      breadcrumb @inquiry.name
    end

    def edit
      authorize @inquiry
      redirect_to admin_inquiry_path(@inquiry)
    end

    def update
      authorize @inquiry

      if @inquiry.update(permitted_attributes(@inquiry))
        redirect_to admin_inquiry_path(@inquiry), notice: t("admin.inquiries.updated"), status: :see_other
      else
        breadcrumb t("admin.inquiries.title"), admin_inquiries_path
        breadcrumb @inquiry.name
        render :show, status: :unprocessable_content
      end
    end

    # Quick status change from the list or the detail view.
    def status
      authorize @inquiry, :status?

      Inquiries::UpdateStatus.new(@inquiry, status: params[:status]).call
      notice = t("admin.inquiries.status_changed", status: Inquiry.human_enum_name(:status, @inquiry.status))

      redirect_back fallback_location: admin_inquiry_path(@inquiry), notice: notice, status: :see_other
    rescue Inquiries::UpdateStatus::InvalidStatus
      redirect_back fallback_location: admin_inquiries_path, alert: t("admin.errors.generic"), status: :see_other
    end

    def destroy
      authorize @inquiry
      @inquiry.destroy!

      redirect_to admin_inquiries_path, notice: t("admin.inquiries.destroyed"), status: :see_other
    end

    private

    def set_inquiry
      @inquiry = Inquiry.find(params[:id])
    end
  end
end
