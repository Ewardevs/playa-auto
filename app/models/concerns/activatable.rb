# Shared behaviour for the catalogue entities that can be switched on and off
# without being deleted (brands, models, categories, FAQs, users).
module Activatable
  extend ActiveSupport::Concern

  included do
    scope :active,   -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end

  def toggle_active!
    update!(active: !active)
  end
end
