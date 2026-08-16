module Admin
  # Singleton resource: the company data every other screen reads from.
  class SettingsController < BaseController
    before_action :set_setting

    def show
      authorize @setting, :show?
      breadcrumb t("admin.settings.title")
    end

    def update
      authorize @setting, :update?

      if @setting.update(permitted_attributes(@setting))
        # The layout memoises the setting per request; clear it so the change
        # shows immediately.
        Current.setting = nil
        redirect_to admin_settings_path, notice: t("admin.settings.updated"), status: :see_other
      else
        breadcrumb t("admin.settings.title")
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_setting
      @setting = Setting.current
    end
  end
end
