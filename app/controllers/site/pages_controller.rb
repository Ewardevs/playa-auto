module Site
  # The institutional pages. All of their copy comes from the admin — nothing
  # here is written into a view.
  class PagesController < BaseController
    def about
      @differentials = Differential.active.ordered
      @vehicle_count = Vehicles::Public.call.count
      @brand_count   = Brand.active.count

      breadcrumb t("site.nav.about")

      seo.title       = site_content.about_title.presence || t("site.nav.about")
      seo.description = site_content.about_description
      seo.image_url   = about_image_url

      public_cache
    end

    def faqs
      @faqs = Faq.active.ordered

      breadcrumb t("site.nav.faqs")

      seo.title       = t("site.faqs.seo.title")
      seo.description = t("site.faqs.seo.description", company: current_setting.company_name)

      public_cache
    end

    def contact
      @inquiry  = Inquiry.new
      @vehicles = Vehicles::Public.call.with_associations.order(:brand_id).limit(200)

      breadcrumb t("site.nav.contact")

      seo.title       = t("site.contact.seo.title")
      seo.description = t("site.contact.seo.description",
                          company: current_setting.company_name, address: current_setting.address)
    end

    private

    def about_image_url
      return unless site_content.about_image.attached?

      url_for(site_content.about_image)
    end
  end
end
