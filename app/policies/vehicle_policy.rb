# frozen_string_literal: true

# Super Admin / Administrador: full control.
# Vendedor: may list, create, edit and change status, but never delete or
#           archive inventory.
# Editor:   no access — the editor role owns site copy, not stock.
class VehiclePolicy < ApplicationPolicy
  def index?  = user.manages_vehicles?
  def show?   = index?
  def create? = user.manages_vehicles?
  def update? = user.manages_vehicles?

  # Destructive actions stay with the catalogue owners.
  def destroy?   = user.manages_catalog?
  def archive?   = user.manages_catalog?
  def restore?   = user.manages_catalog?
  def duplicate? = user.manages_vehicles?

  # Quick status switch from the table row.
  def status? = user.manages_vehicles?

  # Only the catalogue owners may feature a vehicle on the future home page.
  def feature? = user.manages_catalog?

  # `on_offer` is deliberately absent: it is derived from the vehicle's Offer and
  # kept in sync by that model. Accepting it here would let the form fight the
  # offer module over the same flag.
  def permitted_attributes
    base = %i[
      brand_id vehicle_model_id category_id year price previous_price mileage
      fuel_type transmission engine color description equipment status
      published_at meta_title meta_description seo_description
    ]
    base << :featured if feature?
    base
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_vehicles? ? scope.all : scope.none
    end
  end
end
