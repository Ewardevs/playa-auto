module Admin
  # Singleton resource: the editable copy of the future public site.
  class ContentController < BaseController
    before_action :set_content

    def show
      authorize @content, :show?
      breadcrumb t("admin.content.title")
    end

    def update
      authorize @content, :update?

      if @content.update(permitted_attributes(@content))
        redirect_to admin_content_path, notice: t("admin.content.updated"), status: :see_other
      else
        breadcrumb t("admin.content.title")
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_content
      @content = SiteContent.current
    end
  end
end
