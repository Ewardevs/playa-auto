# Singleton row: the one place company information lives. Nothing in the app
# should hardcode a phone number, address or company name — read it from here.
class Setting < ApplicationRecord
  include Auditable

  audits :company_name, :phone, :whatsapp, :email, :address, :currency

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
  def self.current
    Current.setting ||= first || create!
  end

  def whatsapp_link
    return if whatsapp.blank?

    "https://wa.me/#{whatsapp.gsub(/\D/, '')}"
  end

  def display_name = company_name

  def audit_label = I18n.t("audit.labels.settings")

  private

  def sync_currency_symbol
    return if currency.blank?

    self.currency_symbol = CURRENCIES.fetch(currency, currency_symbol.presence || "$")
  end
end
