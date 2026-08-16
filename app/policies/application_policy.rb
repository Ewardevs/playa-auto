# frozen_string_literal: true

# Base policy. Everything is denied unless a subclass opens it up, so a missing
# policy method can never accidentally grant access.
#
# Role capabilities live on User (`manages_catalog?`, `manages_content?`, …)
# rather than being spelled out as role comparisons here, which keeps the rules
# in one place and the policies readable.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "sesión requerida" if user.blank?

    @user   = user
    @record = record
  end

  def index?   = false
  def show?    = index?
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "sesión requerida" if user.blank?

      @user  = user
      @scope = scope
    end

    def resolve = scope.none

    private

    attr_reader :user, :scope
  end

  private

  # Shared shorthand used by the catalogue policies.
  def super_admin? = user.super_admin?
end
