class PortalController < ApplicationController
  layout "portal"

  # Página de entrada de la demo: elige entre las ediciones públicas.
  def show
    @company_name = Setting.current.company_name
  end

  # robots.txt de raíz. Las ediciones en evaluación publican su propio noindex;
  # acá solo se señala el sitemap de la edición principal (/v1).
  def robots
    render plain: <<~ROBOTS, content_type: "text/plain"
      User-agent: *
      Allow: /
      Disallow: /admin
      Disallow: /ingresar
      Disallow: /contrasena

      Sitemap: #{site_sitemap_url(format: :xml)}
    ROBOTS
  end
end
