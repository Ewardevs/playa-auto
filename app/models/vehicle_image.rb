class VehicleImage < ApplicationRecord
  CONTENT_TYPES = %w[image/jpeg image/png image/webp image/avif].freeze
  MAX_SIZE      = 10.megabytes

  belongs_to :vehicle, touch: true

  has_one_attached :file do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 160, 120 ], preprocessed: true
    attachable.variant :card,  resize_to_fill: [ 640, 480 ]
    # Vertical, para las cards en formato afiche de Site2. Se agrega en lugar de
    # recortar la variante :card en CSS, que tiraría a la basura la mitad del
    # ancho descargado. Las demás variantes quedan exactamente como estaban.
    attachable.variant :poster, resize_to_fill: [ 720, 900 ]
    attachable.variant :large, resize_to_limit: [ 1600, 1200 ]
  end

  validate :file_attached
  validate :file_is_a_supported_image

  before_create :assign_position
  after_create_commit  :ensure_a_main_image
  after_destroy_commit :promote_next_main_image

  scope :ordered, -> { order(:position, :id) }
  scope :main,    -> { where(main: true) }

  # Promotes this image and demotes the previous one atomically, so the partial
  # unique index can never be violated.
  def make_main!
    transaction do
      self.class.where(vehicle_id: vehicle_id, main: true).where.not(id: id).update_all(main: false)
      update!(main: true)
    end
  end

  def variant_or_original(name)
    return file unless file.variable?

    file.variant(name)
  end

  private

  def assign_position
    self.position ||= 0
    return unless position.zero?

    self.position = (self.class.where(vehicle_id: vehicle_id).maximum(:position) || -1) + 1
  end

  # The first image uploaded for a vehicle becomes its main image.
  def ensure_a_main_image
    return if self.class.where(vehicle_id: vehicle_id, main: true).exists?

    update_column(:main, true)
  end

  def promote_next_main_image
    return unless main?

    self.class.where(vehicle_id: vehicle_id).ordered.first&.update_column(:main, true)
  end

  def file_attached
    errors.add(:file, :blank) unless file.attached?
  end

  def file_is_a_supported_image
    return unless file.attached?

    errors.add(:file, :invalid_image_type) unless file.content_type.in?(CONTENT_TYPES)
    errors.add(:file, :image_too_large) if file.byte_size > MAX_SIZE
  end
end
