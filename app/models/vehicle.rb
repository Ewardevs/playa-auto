class Vehicle < ApplicationRecord
  include Sluggable
  include Auditable
  include Discard::Model

  # Archived vehicles are excluded by the query objects rather than by a
  # default_scope, so admin screens can opt back in explicitly.

  slug_from :slug_source
  audits :price, :previous_price, :status, :featured, :on_offer, :mileage,
         :year, :category_id, :brand_id, :vehicle_model_id

  enum :status, { available: 0, reserved: 1, sold: 2, hidden: 3 }, validate: true
  enum :fuel_type,
       { gasoline: 0, diesel: 1, hybrid: 2, electric: 3, flex: 4, gas: 5 },
       prefix: :fuel, validate: true
  enum :transmission,
       { manual: 0, automatic: 1, cvt: 2, semi_automatic: 3 },
       prefix: true, validate: true

  MIN_YEAR = 1950
  MAX_PRICE = 100_000_000

  belongs_to :brand,         counter_cache: :vehicles_count
  belongs_to :vehicle_model, counter_cache: :vehicles_count
  belongs_to :category,      counter_cache: :vehicles_count
  belongs_to :user, optional: true

  has_many :images, -> { order(:position, :id) },
           class_name: "VehicleImage", dependent: :destroy, inverse_of: :vehicle
  has_many :inquiries, dependent: :nullify
  has_one  :offer, dependent: :destroy

  accepts_nested_attributes_for :images, allow_destroy: true

  before_validation :assign_code, on: :create
  before_validation :assign_published_at, on: :create

  validates :year, presence: true,
                   numericality: {
                     only_integer: true,
                     greater_than_or_equal_to: MIN_YEAR,
                     less_than_or_equal_to: ->(_) { Date.current.year + 2 }
                   }
  validates :price, presence: true,
                    numericality: { greater_than: 0, less_than_or_equal_to: MAX_PRICE }
  validates :previous_price,
            numericality: { greater_than: 0, less_than_or_equal_to: MAX_PRICE },
            allow_nil: true
  validates :mileage, presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :code, presence: true, uniqueness: true
  validates :engine, :color, length: { maximum: 80 }, allow_blank: true
  validates :description, :equipment, length: { maximum: 10_000 }, allow_blank: true

  validate :previous_price_above_price
  validate :vehicle_model_belongs_to_brand

  scope :ordered,      -> { order(created_at: :desc) }
  scope :featured,     -> { where(featured: true) }
  scope :not_featured, -> { where(featured: false) }
  scope :offered,      -> { where(on_offer: true) }
  scope :published,    -> { where.not(published_at: nil).where(published_at: ..Time.current) }
  scope :most_viewed,  -> { order(views_count: :desc, created_at: :desc) }
  scope :most_inquired, -> { order(inquiries_count: :desc, created_at: :desc) }

  # Everything the admin tables and dashboard need, without N+1. Variant records
  # are preloaded too, otherwise each thumbnail costs an extra query.
  scope :with_associations, -> {
    includes(
      :brand, :vehicle_model, :category, :offer,
      images: { file_attachment: { blob: :variant_records } }
    )
  }

  def display_name = "#{brand&.name} #{vehicle_model&.name} #{year}".squish

  def to_param = slug

  def slug_source
    [ brand&.name, vehicle_model&.name, year ].compact_blank.join(" ")
  end

  def main_image
    images.detect(&:main?) || images.first
  end

  # The price the customer actually pays right now.
  def current_price
    running_offer&.promo_price || price
  end

  def running_offer
    offer if offer&.running?
  end

  def discounted? = running_offer.present?

  def discount_percentage
    return unless discounted? && offer.previous_price.to_d.positive?

    (((offer.previous_price - offer.promo_price) / offer.previous_price) * 100).round
  end

  def published? = published_at.present? && published_at <= Time.current

  def archived? = discarded?

  # Cheap, non-blocking view counter for the future public site. Skips
  # validations and callbacks on purpose.
  def register_view!
    self.class.where(id: id).update_all("views_count = views_count + 1")
  end

  private

  # Drawn from a PostgreSQL sequence so concurrent creates can never collide.
  def assign_code
    return if code.present?

    next_value = self.class.connection.select_value("SELECT nextval('vehicle_codes')")
    self.code = format("V-%05d", next_value)
  end

  def assign_published_at
    self.published_at ||= Time.current
  end

  def previous_price_above_price
    return if previous_price.blank? || price.blank?
    return if previous_price > price

    errors.add(:previous_price, :must_exceed_price)
  end

  def vehicle_model_belongs_to_brand
    return if vehicle_model.blank? || brand_id.blank?
    return if vehicle_model.brand_id == brand_id

    errors.add(:vehicle_model_id, :not_in_brand)
  end
end
