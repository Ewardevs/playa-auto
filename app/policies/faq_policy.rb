# frozen_string_literal: true

class FaqPolicy < ApplicationPolicy
  def index?   = user.manages_content?
  def show?    = index?
  def create?  = user.manages_content?
  def update?  = user.manages_content?
  def toggle?  = user.manages_content?
  def destroy? = user.manages_content?

  def permitted_attributes = %i[question answer position active]

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_content? ? scope.all : scope.none
    end
  end
end
