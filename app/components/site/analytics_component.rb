# frozen_string_literal: true

module Site
  # Third-party analytics, in exactly one place.
  #
  # Nothing is injected unless the playa configured an id in Configuración, so a
  # fresh install ships zero third-party scripts. Adding another provider means
  # editing this component and nothing else.
  class AnalyticsComponent < ApplicationComponent
    def render?
      Rails.env.production? && current_setting.analytics?
    end

    private

    def ga_id  = current_setting.google_analytics_id.presence
    def gtm_id = current_setting.google_tag_manager_id.presence
    def pixel_id = current_setting.meta_pixel_id.presence

    # Ids are echoed into JavaScript, so only the characters these providers
    # actually use are allowed through.
    def safe(id) = id.to_s.gsub(/[^A-Za-z0-9\-_]/, "")
  end
end
