# frozen_string_literal: true

# Shared rules for the catalogue taxonomies (brands, models, categories).
#
# Sellers can *read* them because the vehicle form needs to populate its
# selects, but only the catalogue owners may change them.
class CatalogPolicy < ApplicationPolicy
  def index?  = user.manages_catalog? || user.manages_vehicles?
  def show?   = index?
  def create? = user.manages_catalog?
  def update? = user.manages_catalog?
  def toggle? = user.manages_catalog?

  # Refuse to delete a taxonomy that still has stock hanging off it; the UI
  # offers deactivation instead.
  def destroy? = user.manages_catalog? && !record_in_use?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.manages_catalog? || user.manages_vehicles? ? scope.all : scope.none
    end
  end

  private

  def record_in_use?
    record.respond_to?(:vehicles_count) && record.vehicles_count.to_i.positive?
  end
end
