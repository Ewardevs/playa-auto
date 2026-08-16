module Site2
  # Base de la segunda web pública.
  #
  # Deliberadamente independiente de Site::BaseController: los dos sitios
  # comparten el dominio (modelos, queries y services), no la presentación. Lo
  # único que se repite acá son cuatro accesores triviales, y eso es más barato
  # que acoplar dos diseños que tienen que poder evolucionar por separado.
  #
  # Sin autenticación y sin acceso a las policies del panel: de este lado solo
  # se lee lo que Vehicles::Public deja salir.
  class BaseController < ApplicationController
    layout "site2"

    helper_method :current_setting, :site_content, :seo, :breadcrumbs, :preview?

    before_action :set_default_seo

    private

    # Mismo nombre que en Site::BaseController a propósito: ApplicationComponent
    # delega `current_setting` y `site_content` a los helpers, así los
    # componentes compartidos funcionan en los dos sitios sin saber en cuál están.
    def current_setting = Setting.current

    def site_content = Current.site_content ||= SiteContent.current

    def seo = @seo ||= SEO::Metadata.new(setting: current_setting, url: request.original_url)

    # Mientras Site2 sea una versión en evaluación no se indexa: dos sitios con
    # el mismo inventario compitiendo entre sí es contenido duplicado. Un solo
    # valor (config/initializers/site2.rb) lo cambia el día que Site2 pase a ser
    # el sitio principal.
    def preview? = Rails.configuration.x.site2.preview

    def set_default_seo
      seo.title       = current_setting.company_name
      seo.description = current_setting.tagline.presence || site_content.hero_subtitle
      seo.canonical   = canonical_url
      seo.noindex! if preview?
    end

    # El canónico deja fuera filtros, orden y paginación: un catálogo filtrado
    # nunca compite consigo mismo.
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
