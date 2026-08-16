module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy toggle reset_password]

    def index
      authorize User
      scope = policy_scope(User).search(params[:q])
      scope = scope.where(role: params[:role]) if User.roles.key?(params[:role])

      @pagy, @users = paginate(scope.ordered.with_attached_avatar)
      breadcrumb t("admin.users.title")
    end

    def show
      authorize @user
      redirect_to edit_admin_user_path(@user)
    end

    def new
      @user = User.new(role: :seller, active: true)
      authorize @user
      breadcrumbs_for_form
    end

    def create
      @user = User.new(permitted_attributes(User))
      # No password given: issue a random one and let the invitee set their own
      # through the recovery email. A known default is never assigned.
      @user.password = SecureRandom.base58(24) if @user.password.blank?
      authorize @user

      if @user.save
        @user.send_reset_password_instructions if password_omitted?
        redirect_to admin_users_path, notice: t("admin.users.created"), status: :see_other
      else
        breadcrumbs_for_form
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @user
      breadcrumbs_for_form
    end

    def update
      authorize @user

      if @user.update(user_params_for_update)
        redirect_to admin_users_path, notice: t("admin.users.updated"), status: :see_other
      else
        breadcrumbs_for_form
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @user
      @user.destroy!

      redirect_to admin_users_path, notice: t("admin.users.destroyed"), status: :see_other
    end

    def toggle
      authorize @user, :toggle?
      @user.toggle_active!

      notice = @user.active? ? t("admin.users.activated") : t("admin.users.deactivated")
      redirect_back fallback_location: admin_users_path, notice: notice, status: :see_other
    rescue ActiveRecord::RecordInvalid => e
      # The model refuses to deactivate the last active Super Admin.
      redirect_back fallback_location: admin_users_path,
                    alert: e.record.errors.full_messages.to_sentence, status: :see_other
    end

    def reset_password
      authorize @user, :reset_password?
      @user.send_reset_password_instructions

      redirect_back fallback_location: admin_users_path,
                    notice: t("admin.users.password_reset", email: @user.email), status: :see_other
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    # Leaving the password blank on edit must not wipe the existing one.
    def user_params_for_update
      attributes = permitted_attributes(@user)
      return attributes if attributes[:password].present?

      attributes.except(:password, :password_confirmation)
    end

    def password_omitted?
      params.dig(:user, :password).blank?
    end

    def breadcrumbs_for_form
      breadcrumb t("admin.users.title"), admin_users_path
      breadcrumb @user.persisted? ? @user.display_name : t("admin.users.new")
    end
  end
end
