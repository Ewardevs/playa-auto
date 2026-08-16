module Site4
  # Base de la cuarta web pública.
  #
  # Igual que Site2 y Site3: independiente en la presentación, idéntica en el
  # dominio. No conoce a Site::, Site2:: ni Site3:: — lo único que comparten los
  # cuatro sitios son los modelos, los query objects, los services y los
  # componentes UI::.
  class BaseController < ApplicationController
    layout "site4"

    helper_method :current_setting, :site_content, :seo, :breadcrumbs, :preview?

    before_action :set_default_seo

    private

    # Mismos nombres que en los otros sitios a propósito: ApplicationComponent
    # delega `current_setting` y `site_content` a los helpers, así los
    # componentes compartidos funcionan sin saber en qué sitio están.
    def current_setting = Setting.current

    def site_content = Current.site_content ||= SiteContent.current

    def seo = @seo ||= SEO::Metadata.new(setting: current_setting, url: request.original_url)

    # Falla cerrado: solo un `false` explícito saca a Site4 del modo evaluación.
    # Si el initializer no llegó a correr, el valor es nil y el sitio se sigue
    # sirviendo con noindex — un despliegue incompleto no puede terminar
    # publicando dos veces el mismo inventario en el índice de Google.
    def preview? = Rails.configuration.x.site4.preview != false

    def set_default_seo
      seo.title       = current_setting.company_name
      seo.description = current_setting.tagline.presence || site_content.hero_subtitle
      seo.canonical   = canonical_url
      seo.noindex! if preview?
    end

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

    def public_cache(minutes: 5)
      return if Rails.env.development?

      expires_in minutes.minutes, public: true
    end
  end
end
