# frozen_string_literal: true

# Headless policy: the dashboard has no record, it is authorized as a symbol
# (`authorize :dashboard, :show?`). Every authenticated user gets a dashboard;
# the individual panels are filtered by their own policies.
class DashboardPolicy < ApplicationPolicy
  def show? = user.present?
end
