# frozen_string_literal: true

# Own account. Every signed-in user may view and edit their own profile and
# password, but privileges are never editable here — `role` and `active` are
# absent from the permitted attributes on purpose.
class ProfilePolicy < ApplicationPolicy
  def show?   = own_record?
  def update? = own_record?
  def edit?   = own_record?

  def permitted_attributes = %i[name phone email avatar]

  private

  def own_record? = record.is_a?(User) && record.id == user.id
end
