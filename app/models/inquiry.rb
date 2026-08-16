class Inquiry < ApplicationRecord
  include Auditable

  audits :status, :user_id

  # `new_lead` rather than `new` — `new` would collide with Ruby's constructor
  # once Rails generates the enum's scopes and predicates.
  enum :status,
       { new_lead: 0, contacted: 1, negotiating: 2, sold: 3, closed: 4 },
       validate: true

  OPEN_STATUSES = %w[new_lead contacted negotiating].freeze

  # Optional: the future public site will also expose a general contact form
  # that isn't tied to a vehicle.
  belongs_to :vehicle, optional: true, counter_cache: :inquiries_count
  belongs_to :user, optional: true

  validates :name, presence: true, length: { maximum: 120 }
  validates :phone, presence: true, length: { maximum: 40 }
  validates :email, length: { maximum: 160 },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    allow_blank: true
  validates :message, length: { maximum: 5_000 }, allow_blank: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :open_inquiries, -> { where(status: OPEN_STATUSES) }
  scope :this_month, -> { where(created_at: Time.current.all_month) }
  scope :with_associations, -> { includes(:user, vehicle: [ :brand, :vehicle_model ]) }

  def display_name = "#{name} — #{vehicle&.display_name || I18n.t('inquiries.general')}"

  def open? = status.in?(OPEN_STATUSES)
end
