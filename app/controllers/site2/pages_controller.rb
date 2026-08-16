module Site2
  # Las páginas institucionales. Todo el copy sale del panel: acá no hay ni una
  # frase escrita en una vista.
  class PagesController < BaseController
    def about
      @differentials = Differential.active.ordered.to_a

      public_scope    = Vehicles::Public.call
      @vehicle_count  = public_scope.count
      @brand_count    = Brand.active.count
      @category_count = Category.active.count

      breadcrumb t("site2.nav.about")

      seo.title       = site_content.about_title.presence || t("site2.about.title_fallback")
      seo.description = site_content.about_description.presence ||
                        t("site2.about.seo.description", company: current_setting.company_name)
      seo.image_url   = about_image_url

      public_cache
    end

    def faqs
      @faqs = Faq.active.ordered.to_a

      breadcrumb t("site2.nav.faqs")

      seo.title       = t("site2.faqs.title")
      seo.description = t("site2.faqs.seo.description", company: current_setting.company_name)

      public_cache
    end

    def contact
      @inquiry  = Inquiry.new
      @vehicles = selectable_vehicles

      breadcrumb t("site2.nav.contact")

      seo.title       = t("site2.contact.title")
      seo.description = t("site2.contact.seo.description",
                          company: current_setting.company_name, address: current_setting.address)
    end

    private

    # Solo alimenta un <select>: se precargan marca y modelo (que forman la
    # etiqueta) y nada más — las fotos no se muestran acá.
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
