class Category < ApplicationRecord
  include Sluggable
  include Activatable
  include Auditable

  slug_from :name
  audits :name, :active

  has_many :vehicles, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 80 },
                   uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(:position, :name) }
  scope :selectable, -> { active.ordered }
  scope :search, ->(term) {
    next all if term.blank?

    where("categories.name ILIKE ?", "%#{sanitize_sql_like(term)}%")
  }

  def display_name = name

  def to_param = slug
end
