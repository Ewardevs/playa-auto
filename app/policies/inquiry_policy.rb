# frozen_string_literal: true

# Sellers work inquiries day to day; only the owners may delete them, so a
# sales record can't be quietly erased.
class InquiryPolicy < ApplicationPolicy
  def index?   = user.manages_inquiries?
  def show?    = index?
  def update?  = user.manages_inquiries?
  def status?  = user.manages_inquiries?
  def destroy? = user.manages_catalog?

  def permitted_attributes = %i[status notes user_id]

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_inquiries? ? scope.all : scope.none
    end
  end
end
