# Singleton row: the one place company information lives. Nothing in the app
# should hardcode a phone number, address or company name — read it from here.
class Setting < ApplicationRecord
  include Auditable

  audits :company_name, :phone, :whatsapp, :email, :address, :currency, :show_sold_vehicles

  CURRENCIES = {
    "USD" => "$",
    "PYG" => "Gs.",
    "EUR" => "€",
    "BRL" => "R$",
    "ARS" => "$"
  }.freeze

  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 160, 160 ], preprocessed: true
  end
  has_one_attached :favicon

  validates :company_name, presence: true, length: { maximum: 120 }
  validates :currency, presence: true, inclusion: { in: CURRENCIES.keys }
  validates :currency_symbol, presence: true, length: { maximum: 8 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  # Anchored at both ends with \z (not $) and \S so a newline can't smuggle a
  # second line into a value that ends up in an href.
  validates :google_maps_url, :instagram_url, :facebook_url, :tiktok_url,
            format: { with: %r{\Ahttps?://\S+\z}, message: :must_be_a_url },
            length: { maximum: 500 },
            allow_blank: true

  before_validation :sync_currency_symbol

  # Memoised per request via Current, so components can call it freely.
  #
  # `Current` only exists inside an execution context (a request or a job).
  # Outside one — a rake task, `rails runner`, a console — reading it raises, so
  # fall back to a direct read: every caller must be able to ask for the company
  # settings without first knowing what wraps it.
  def self.current
    Current.setting ||= load_record
  rescue NoMethodError
    load_record
  end

  def self.load_record = first || create!
  private_class_method :load_record

  # Public site entry point for the main conversion channel. The message is
  # optional so a plain "Hablar por WhatsApp" and a vehicle-specific enquiry
  # both come from here — the number is never written anywhere else.
  def whatsapp_link(message: nil)
    return if whatsapp.blank?

    url = "https://wa.me/#{whatsapp.gsub(/\D/, '')}"
    url += "?text=#{CGI.escape(message)}" if message.present?
    url
  end

  def whatsapp? = whatsapp.present?

  # [[:instagram, url], …] for whichever networks are actually configured.
  def social_links
    {
      instagram: instagram_url,
      facebook: facebook_url,
      tiktok: tiktok_url
    }.compact_blank
  end

  # Opening hours are stored as free text, one line per row.
  def opening_hours_lines
    opening_hours.to_s.lines.map(&:strip).reject(&:blank?)
  end

  def analytics? = [ google_analytics_id, google_tag_manager_id, meta_pixel_id ].any?(&:present?)

  def display_name = company_name

  def audit_label = I18n.t("audit.labels.settings")

  private

  def sync_currency_symbol
    return if currency.blank?

    self.currency_symbol = CURRENCIES.fetch(currency, currency_symbol.presence || "$")
  end
end
