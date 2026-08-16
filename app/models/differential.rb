# A selling point shown on the public site ("Vehículos seleccionados",
# "Documentación transparente", …).
#
# Modelled rather than hardcoded because these claims are the playa's, not the
# software's — they change, and only the business may change them.
class Differential < ApplicationRecord
  include Activatable
  include Auditable

  audits :title, :description, :active, :position

  # Restricted to icons the design system actually ships, so a typo in the
  # admin can never render a blank space on the home page.
  ICONS = %w[
    check_circle shield car key percent phone users gauge star tag file_text
  ].freeze

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 240 }, allow_blank: true
  validates :icon, presence: true, inclusion: { in: ICONS }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :assign_position, on: :create

  scope :ordered, -> { order(:position, :id) }

  def display_name = title

  private

  def assign_position
    self.position = (self.class.maximum(:position) || -1) + 1 if position.blank? || position.zero?
  end
end
