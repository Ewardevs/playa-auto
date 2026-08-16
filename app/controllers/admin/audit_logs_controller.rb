module Admin
  class AuditLogsController < BaseController
    def index
      authorize AuditLog
      scope = policy_scope(AuditLog).includes(:user)
      scope = scope.where(action: params[:action_name]) if params[:action_name].present?
      scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?

      @pagy, @logs = paginate(scope.order(created_at: :desc), limit: 40)
      @actions = policy_scope(AuditLog).distinct.pluck(:action).sort

      breadcrumb t("admin.audit_logs.title")
    end
  end
end
