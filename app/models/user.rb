class User < ApplicationRecord
  include Activatable
  include Auditable

  audits :role, :active, :email, :name

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable

  # Ordered from most to least privileged. Pundit reads these through the
  # predicate methods below rather than comparing raw values.
  enum :role, { super_admin: 0, admin: 1, seller: 2, editor: 3 }, validate: true

  has_one_attached :avatar

  has_many :vehicles,   dependent: :nullify
  has_many :inquiries,  dependent: :nullify
  has_many :audit_logs, dependent: :nullify

  validates :name, presence: true, length: { maximum: 120 }
  validates :phone, length: { maximum: 40 }, allow_blank: true

  # The last super admin must never be locked out of the panel.
  validate :cannot_demote_last_super_admin
  validate :cannot_deactivate_last_super_admin

  scope :ordered, -> { order(:name) }
  scope :search, ->(term) {
    next all if term.blank?

    where("users.name ILIKE :q OR users.email ILIKE :q", q: "%#{sanitize_sql_like(term)}%")
  }

  def display_name = name.presence || email

  def initials
    display_name.to_s.split.first(2).map { |part| part[0] }.join.upcase
  end

  # Devise: deactivated users cannot sign in, and are signed out on next request.
  def active_for_authentication? = super && active?

  def inactive_message = active? ? super : :account_inactive

  def manages_users?    = super_admin?
  def manages_settings? = super_admin?
  def manages_catalog?  = super_admin? || admin?
  def manages_content?  = super_admin? || admin? || editor?
  def manages_vehicles? = super_admin? || admin? || seller?
  def manages_inquiries? = super_admin? || admin? || seller?

  def self.last_super_admin?(user)
    user.super_admin? && where(role: :super_admin).where.not(id: user.id).none?
  end

  private

  def cannot_demote_last_super_admin
    return unless persisted? && role_changed? && role_was == "super_admin"
    return if User.where(role: :super_admin).where.not(id: id).exists?

    errors.add(:role, :last_super_admin)
  end

  def cannot_deactivate_last_super_admin
    return unless persisted? && active_changed? && !active? && super_admin?
    return if User.where(role: :super_admin, active: true).where.not(id: id).exists?

    errors.add(:active, :last_super_admin)
  end
end
