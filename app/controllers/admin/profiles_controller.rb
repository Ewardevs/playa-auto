module Admin
  # The signed-in user's own account. Privileges are not editable here: the
  # policy's permitted attributes exclude `role` and `active` entirely.
  class ProfilesController < BaseController
    before_action :set_profile

    def show
      authorize @profile, :show?, policy_class: ProfilePolicy
      breadcrumb t("admin.profile.title")
    end

    def update
      authorize @profile, :update?, policy_class: ProfilePolicy

      if @profile.update(profile_params)
        redirect_to admin_profile_path, notice: t("admin.profile.updated"), status: :see_other
      else
        breadcrumb t("admin.profile.title")
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_profile
      @profile = current_user
    end

    # Read straight off ProfilePolicy — `role` and `active` are not in that list,
    # so a user cannot escalate their own privileges by posting extra fields.
    def profile_params
      allowed = ProfilePolicy.new(current_user, @profile).permitted_attributes
      params.require(:user).permit(*allowed)
    end
  end
end
