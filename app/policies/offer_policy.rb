# frozen_string_literal: true

class OfferPolicy < ApplicationPolicy
  def index?  = user.manages_catalog? || user.manages_vehicles?
  def show?   = index?
  def create? = user.manages_catalog?
  def update? = user.manages_catalog?
  def toggle? = user.manages_catalog?
  def destroy? = user.manages_catalog?

  # `previous_price` is deliberately absent: it is copied from the vehicle's
  # list price by the model, so it can't be set from a form or a crafted request.
  def permitted_attributes
    %i[promo_price starts_on ends_on active]
  end

  # The vehicle is chosen once. Moving a live offer to a different vehicle would
  # silently change the price it was published against.
  def permitted_attributes_for_create
    permitted_attributes + %i[vehicle_id]
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_catalog? || user.manages_vehicles? ? scope.all : scope.none
    end
  end
end
