class Brand < ApplicationRecord
  include Sluggable
  include Activatable
  include Auditable

  slug_from :name
  audits :name, :active

  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 96, 96 ], preprocessed: true
    attachable.variant :medium, resize_to_limit: [ 320, 320 ]
  end

  has_many :vehicle_models, dependent: :restrict_with_error
  has_many :vehicles,       dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 80 },
                   uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(:position, :name) }
  scope :search, ->(term) {
    next all if term.blank?

    where("brands.name ILIKE ?", "%#{sanitize_sql_like(term)}%")
  }
  # Only brands that can actually be picked when creating a vehicle.
  scope :selectable, -> { active.ordered }

  def display_name = name

  def to_param = slug
end
