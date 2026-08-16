# Generates stable, URL-friendly slugs for records the future public site will
# expose. Declared per model with `slug_from`:
#
#   class Brand < ApplicationRecord
#     include Sluggable
#     slug_from :name
#   end
#
# Slugs are generated once on create and then left alone, so public URLs stay
# stable when a record is renamed. Call #regenerate_slug! to force a rebuild.
module Sluggable
  extend ActiveSupport::Concern

  FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  included do
    class_attribute :slug_source_method, default: :name, instance_writer: false
    class_attribute :slug_scope_column,  default: nil,   instance_writer: false

    before_validation :assign_slug
    validates :slug, presence: true, format: { with: FORMAT }
    validate  :slug_must_be_available
  end

  class_methods do
    # `scope:` limits uniqueness to a column, e.g. model names within a brand.
    def slug_from(method, scope: nil)
      self.slug_source_method = method
      self.slug_scope_column  = scope
    end
  end

  def regenerate_slug!
    self.slug = nil
    assign_slug
    save!
  end

  private

  def assign_slug
    return if slug.present?

    base = public_send(slug_source_method).to_s.parameterize
    return if base.blank?

    self.slug = next_available_slug(base)
  end

  def next_available_slug(base)
    candidate = base
    suffix    = 2

    while slug_taken?(candidate)
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end

    candidate
  end

  def slug_taken?(candidate)
    relation = self.class.unscoped.where(slug: candidate)
    relation = relation.where(slug_scope_column => self[slug_scope_column]) if slug_scope_column
    relation = relation.where.not(id: id) if persisted?
    relation.exists?
  end

  def slug_must_be_available
    return if slug.blank?

    errors.add(:slug, :taken) if slug_taken?(slug)
  end
end
