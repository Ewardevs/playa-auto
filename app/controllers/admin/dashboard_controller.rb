module Admin
  class DashboardController < BaseController
    def show
      authorize :dashboard, :show?

      @dashboard = Dashboard::Overview.new(user: current_user)
    end
  end
end
