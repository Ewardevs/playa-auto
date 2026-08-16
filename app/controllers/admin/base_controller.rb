module Admin
  # Every admin screen inherits from here: authenticated, authorized, and
  # rendered inside the admin layout. Nothing under /admin is reachable without
  # a signed-in user whose policy allows the action.
  class BaseController < ApplicationController
    include Pundit::Authorization

    layout "admin"

    before_action :authenticate_user!

    # Fail closed: an action that forgets to authorize raises instead of
    # silently exposing data.
    #
    # Expressed as conditions rather than `only:`/`except:` so controllers
    # without an `index` action (the dashboard, the singleton resources) don't
    # trip Rails' missing-callback-action check.
    after_action :verify_authorized,    unless: :index_action?
    after_action :verify_policy_scoped, if:     :index_action?

    rescue_from Pundit::NotAuthorizedError, with: :deny_access
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    helper_method :current_setting, :breadcrumbs

    private

    def current_setting = Setting.current

    def index_action? = action_name == "index"

    # Controllers declare their trail with `breadcrumb "Vehículos", admin_vehicles_path`.
    def breadcrumb(label, path = nil)
      breadcrumbs << [ label, path ]
    end

    def breadcrumbs
      @breadcrumbs ||= []
    end

    def deny_access(exception)
      Rails.logger.warn(
        "[authz] denegado user=#{current_user&.id} policy=#{exception.policy.class} query=#{exception.query}"
      )

      respond_to do |format|
        format.html do
          redirect_back fallback_location: admin_root_path,
                        alert: t("admin.errors.not_authorized"),
                        status: :see_other
        end
        format.turbo_stream do
          redirect_back fallback_location: admin_root_path,
                        alert: t("admin.errors.not_authorized"),
                        status: :see_other
        end
        format.json { render json: { error: t("admin.errors.not_authorized") }, status: :forbidden }
      end
    end

    def record_not_found
      redirect_to admin_root_path, alert: t("admin.errors.not_found"), status: :see_other
    end

    # Pagy
    include Pagy::Method

    def paginate(scope, limit: 20)
      pagy(scope, limit: limit)
    end
  end
end
