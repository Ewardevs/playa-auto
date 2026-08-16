# frozen_string_literal: true

class CategoryPolicy < CatalogPolicy
  def permitted_attributes = %i[name description active position meta_title meta_description]
end
