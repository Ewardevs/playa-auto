module Site4
  # Las páginas institucionales. Todo el copy sale del panel.
  class PagesController < BaseController
    def about
      @differentials = Differential.active.ordered.to_a

      public_scope    = Vehicles::Public.call
      @vehicle_count  = public_scope.count
      @brand_count    = Brand.active.count
      @category_count = Category.active.count

      breadcrumb t("site4.nav.about")

      seo.title       = site_content.about_title.presence || t("site4.about.title_fallback")
      seo.description = site_content.about_description.presence ||
                        t("site4.about.seo.description", company: current_setting.company_name)
      seo.image_url   = about_image_url

      public_cache
    end

    def faqs
      @faqs = Faq.active.ordered.to_a

      breadcrumb t("site4.nav.faqs")

      seo.title       = t("site4.faqs.title")
      seo.description = t("site4.faqs.seo.description", company: current_setting.company_name)

      public_cache
    end

    def contact
      @inquiry  = Inquiry.new
      @vehicles = selectable_vehicles

      breadcrumb t("site4.nav.contact")

      seo.title       = t("site4.contact.title")
      seo.description = t("site4.contact.seo.description",
                          company: current_setting.company_name, address: current_setting.address)
    end

    private

    # Solo alimenta un <select>: marca y modelo forman la etiqueta, las fotos no
    # se muestran acá.
    def selectable_vehicles
      Vehicles::Public.call
                      .includes(:brand, :vehicle_model)
                      .order(:brand_id, :vehicle_model_id)
                      .limit(200)
    end

    def about_image_url
      return unless site_content.about_image.attached?

      url_for(site_content.about_image)
    end
  end
end
