# frozen_string_literal: true

# User administration belongs to the Super Admin alone.
#
# The central rule from the brief — "a normal user must never be able to change
# their own permissions" — is enforced here rather than in the form: `role` and
# `active` are stripped from the permitted attributes whenever the record being
# edited is the acting user.
class UserPolicy < ApplicationPolicy
  def index?  = user.manages_users?
  def show?   = user.manages_users?
  def create? = user.manages_users?
  def update? = user.manages_users?

  # Nobody deletes or deactivates themselves.
  def destroy? = user.manages_users? && !own_record?
  def toggle?  = user.manages_users? && !own_record?

  def reset_password? = user.manages_users?

  # Only a Super Admin editing somebody else may touch privileges.
  def change_privileges? = user.manages_users? && !own_record?

  def permitted_attributes
    attributes = %i[name email phone avatar]
    attributes += %i[role active] if change_privileges?
    attributes += %i[password password_confirmation]
    attributes
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_users? ? scope.all : scope.none
    end
  end

  private

  def own_record? = record.is_a?(User) && record.id == user.id
end
