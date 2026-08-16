# frozen_string_literal: true

class AuditLogPolicy < ApplicationPolicy
  def index? = user.manages_catalog?
  def show?  = index?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_catalog? ? scope.all : scope.none
    end
  end
end
