module Site
  class OffersController < BaseController
    include Pagy::Method

    PER_PAGE = 12

    def index
      @pagy, @vehicles = pagy(Vehicles::OnOffer.call, limit: PER_PAGE)

      breadcrumb t("site.nav.offers")

      seo.title       = t("site.offers.seo.title")
      seo.description = t("site.offers.seo.description", count: @pagy.count, company: current_setting.company_name)
      seo.noindex! if @pagy.page > 1

      public_cache
    end
  end
end
