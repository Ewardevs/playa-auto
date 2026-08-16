# Singleton row holding the editable copy of the future public site. Kept apart
# from Setting because this is marketing content (owned by the Editor role)
# rather than configuration (owned by the Super Admin).
class SiteContent < ApplicationRecord
  include Auditable

  audits :hero_title, :hero_subtitle, :about_title

  has_one_attached :hero_image do |attachable|
    attachable.variant :preview, resize_to_limit: [ 640, 360 ], preprocessed: true
  end
  has_one_attached :about_image do |attachable|
    attachable.variant :preview, resize_to_limit: [ 640, 360 ], preprocessed: true
  end

  validates :hero_title, :hero_subtitle, :about_title, length: { maximum: 200 }, allow_blank: true
  validates :hero_button_label, length: { maximum: 60 }, allow_blank: true
  validates :hero_text, :about_description, length: { maximum: 5_000 }, allow_blank: true
  # Absolute URL or site-relative path. Anchored at both ends so a newline can't
  # smuggle a second line into the rendered href.
  validates :hero_button_url,
            format: { with: %r{\A(https?://|/)\S*\z}, message: :must_be_a_url },
            length: { maximum: 500 },
            allow_blank: true

  def self.current
    first || create!
  end

  def display_name = I18n.t("audit.labels.site_content")
end
