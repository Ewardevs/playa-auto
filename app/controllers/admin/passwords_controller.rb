module Admin
  # Password change for the signed-in user. Requires the current password, and
  # keeps the session alive afterwards so the change doesn't sign them out.
  class PasswordsController < BaseController
    before_action :set_account

    def edit
      authorize @account, :edit?, policy_class: ProfilePolicy
      breadcrumb t("admin.profile.title"), admin_profile_path
      breadcrumb t("admin.profile.sections.password")
    end

    def update
      authorize @account, :update?, policy_class: ProfilePolicy

      if @account.update_with_password(password_params)
        bypass_sign_in(@account)
        redirect_to admin_profile_path, notice: t("admin.profile.password_updated"), status: :see_other
      else
        breadcrumb t("admin.profile.title"), admin_profile_path
        breadcrumb t("admin.profile.sections.password")
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_account
      @account = current_user
    end

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
  end
end
