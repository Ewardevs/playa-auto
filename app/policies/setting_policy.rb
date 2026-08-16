# frozen_string_literal: true

# Global configuration is Super Admin only — the brief explicitly keeps
# sellers and administrators out of "configuraciones globales".
class SettingPolicy < ApplicationPolicy
  def show?   = user.manages_settings?
  def update? = user.manages_settings?

  def permitted_attributes
    %i[
      company_name tagline phone whatsapp email address opening_hours
      google_maps_url instagram_url facebook_url tiktok_url
      currency locale logo favicon
    ]
  end
end
