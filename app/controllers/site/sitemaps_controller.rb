module Site
  # sitemap.xml and robots.txt, generated from the same public scope the site
  # renders — a vehicle that is hidden, archived or unpublished can never be
  # advertised to a crawler.
  class SitemapsController < BaseController
    layout false

    def show
      @pages    = static_pages
      @vehicles = Vehicles::Public.call.select(:slug, :updated_at).order(updated_at: :desc)
      @brands   = Brand.active.where(vehicles_count: 1..).select(:slug, :updated_at)

      respond_to { |format| format.xml }
      public_cache(minutes: 60)
    end

    def robots
      render plain: robots_body, content_type: "text/plain"
      public_cache(minutes: 60)
    end

    private

    def static_pages
      [
        [ site_root_url, 1.0, "daily" ],
        [ site_vehicles_url, 0.9, "daily" ],
        [ site_offers_url, 0.8, "daily" ],
        [ site_about_url, 0.6, "monthly" ],
        [ site_faqs_url, 0.5, "monthly" ],
        [ site_contact_url, 0.6, "monthly" ]
      ]
    end

    def robots_body
      <<~ROBOTS
        User-agent: *
        Allow: /
        Disallow: /admin
        Disallow: /ingresar
        Disallow: /contrasena
        Disallow: /consultas
        Disallow: /*?orden=
        Disallow: /*?page=

        Sitemap: #{site_sitemap_url(format: :xml)}
      ROBOTS
    end
  end
end
