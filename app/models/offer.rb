class Offer < ApplicationRecord
  include Auditable

  audits :promo_price, :previous_price, :starts_on, :ends_on, :active

  belongs_to :vehicle

  validates :vehicle_id, uniqueness: true
  validates :promo_price,
            presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: Vehicle::MAX_PRICE }
  validates :starts_on, :ends_on, presence: true

  validate :ends_on_after_starts_on
  validate :promo_price_below_previous_price

  # The reference price is copied from the vehicle, never typed in: an offer
  # must not be able to advertise a "before" price the playa never asked for.
  before_validation :snapshot_list_price

  after_save    :sync_vehicle_offer_flag
  after_destroy :sync_vehicle_offer_flag

  scope :ordered, -> { order(starts_on: :desc) }
  scope :enabled, -> { where(active: true) }
  scope :running, -> {
    enabled.where(starts_on: ..Date.current).where(ends_on: Date.current..)
  }
  scope :with_associations, -> { includes(vehicle: [ :brand, :vehicle_model ]) }

  # Active *and* inside its date window.
  def running?
    active? && starts_on.present? && ends_on.present? &&
      starts_on <= Date.current && ends_on >= Date.current
  end

  def scheduled? = active? && starts_on.present? && starts_on > Date.current

  def expired? = ends_on.present? && ends_on < Date.current

  def state
    return :inactive  unless active?
    return :expired   if expired?
    return :scheduled if scheduled?

    :running
  end

  def discount_percentage
    return 0 if previous_price.to_d.zero?

    (((previous_price - promo_price) / previous_price) * 100).round
  end

  def display_name = vehicle&.display_name.to_s

  private

  def snapshot_list_price
    self.previous_price = vehicle.price if vehicle.present?
  end

  def ends_on_after_starts_on
    return if starts_on.blank? || ends_on.blank?
    return if ends_on >= starts_on

    errors.add(:ends_on, :must_follow_start)
  end

  def promo_price_below_previous_price
    return if promo_price.blank? || previous_price.blank?
    return if promo_price < previous_price

    errors.add(:promo_price, :must_be_below_previous)
  end

  # Keeps the denormalised flag on the vehicle in step, so the catalogue can
  # filter on a single indexed column.
  def sync_vehicle_offer_flag
    return if vehicle.blank?

    vehicle.update_column(:on_offer, destroyed? ? false : running?)
  end
end
