module Site
  class HomeController < BaseController
    FEATURED = 6
    OFFERS   = 3

    def show
      @featured      = Vehicles::Featured.call(limit: FEATURED)
      @offers        = Vehicles::OnOffer.call(limit: OFFERS)
      @differentials = Differential.active.ordered.to_a
      @brands        = Brand.active.ordered.with_attached_logo.to_a
      @vehicle_count = Vehicles::Public.call.count

      # Selects for the hero search, loaded once rather than per component.
      @categories = Category.active.ordered.to_a

      seo.title       = site_content.hero_title.presence || current_setting.company_name
      seo.description = site_content.hero_subtitle.presence || current_setting.tagline
      seo.image_url   = hero_image_url

      public_cache
    end

    private

    def hero_image_url
      return unless site_content.hero_image.attached?

      url_for(site_content.hero_image)
    end
  end
end
