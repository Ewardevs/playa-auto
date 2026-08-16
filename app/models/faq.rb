class Faq < ApplicationRecord
  include Activatable
  include Auditable

  audits :question, :active, :position

  validates :question, presence: true, length: { maximum: 300 }
  validates :answer,   presence: true, length: { maximum: 5_000 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :assign_position, on: :create

  scope :ordered, -> { order(:position, :id) }

  def display_name = question

  private

  def assign_position
    self.position = (self.class.maximum(:position) || -1) + 1 if position.blank? || position.zero?
  end
end
