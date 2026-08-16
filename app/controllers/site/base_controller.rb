module Site
  # Base for every public page.
  #
  # Holds what the whole site needs — company data, SEO defaults, breadcrumbs —
  # so no page controller repeats it. Deliberately has no authentication and no
  # access to admin policies: this side of the app only reads published data.
  class BaseController < ApplicationController
    layout "site"

    helper_method :current_setting, :site_content, :seo, :breadcrumbs

    before_action :set_default_seo

    private

    # One query per request, memoised for every component on the page.
    def current_setting = Setting.current

    def site_content = Current.site_content ||= SiteContent.current

    # Per-page SEO, defaulted here and overridden by each action.
    def seo = @seo ||= SEO::Metadata.new(setting: current_setting, url: request.original_url)

    def set_default_seo
      seo.title       = current_setting.company_name
      seo.description = current_setting.tagline.presence || site_content.hero_subtitle
      seo.canonical   = canonical_url
    end

    # Canonical strips filters, sorting and pagination so a filtered catalogue
    # never competes with itself in search results.
    def canonical_url
      url_for(only_path: false, params: {})
    rescue ActionController::UrlGenerationError
      request.original_url.split("?").first
    end

    def breadcrumb(label, path = nil)
      breadcrumbs << [ label, path ]
    end

    def breadcrumbs
      @breadcrumbs ||= []
    end

    # Public pages are cacheable by intermediaries for a short while; the
    # catalogue changes when the playa publishes, not by the second.
    def public_cache(minutes: 5)
      return if Rails.env.development?

      expires_in minutes.minutes, public: true
    end
  end
end
