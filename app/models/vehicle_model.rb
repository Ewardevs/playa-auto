class VehicleModel < ApplicationRecord
  include Sluggable
  include Activatable
  include Auditable

  # Model names are only unique inside their brand.
  slug_from :name, scope: :brand_id
  audits :name, :active, :brand_id

  # No counter cache here: brands.vehicles_count counts vehicles, not models.
  belongs_to :brand, inverse_of: :vehicle_models
  has_many :vehicles, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 80 },
                   uniqueness: { scope: :brand_id, case_sensitive: false }

  scope :ordered, -> { order(:name) }
  scope :for_brand, ->(brand_id) { where(brand_id: brand_id) if brand_id.present? }
  scope :selectable, -> { active.ordered }
  scope :search, ->(term) {
    next all if term.blank?

    joins(:brand).where(
      "vehicle_models.name ILIKE :q OR brands.name ILIKE :q",
      q: "%#{sanitize_sql_like(term)}%"
    )
  }

  def display_name = "#{brand.name} #{name}"
end
