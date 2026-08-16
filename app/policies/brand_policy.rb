# frozen_string_literal: true

class BrandPolicy < CatalogPolicy
  def permitted_attributes = %i[name logo active position meta_title meta_description]
end
