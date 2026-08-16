# frozen_string_literal: true

class VehicleModelPolicy < CatalogPolicy
  def permitted_attributes = %i[brand_id name active]
end
