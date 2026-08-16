module Site2
  class HomeController < BaseController
    def show
      @featured      = Vehicles::Featured.call(limit: 6)
      @offers        = Vehicles::OnOffer.call(limit: 3)
      @differentials = Differential.active.ordered.to_a
      @categories    = Category.active.ordered.to_a

      load_counters

      seo.description = site_content.hero_subtitle.presence || current_setting.tagline.presence
      public_cache
    end

    private

    # Las cifras del encabezado. Tres consultas agregadas y ninguna colección
    # cargada de más: los contadores no necesitan las filas.
    def load_counters
      public_scope = Vehicles::Public.call

      @stock_count    = public_scope.count
      @brand_count    = Brand.active.count
      # Se reutiliza el query object y se le quitan las preocupaciones de
      # presentación (precarga y orden), que en un COUNT solo estorban.
      @offer_count    = Vehicles::OnOffer.new.results.except(:includes, :order).count
      @category_stock = public_scope.group(:category_id).count
    end
  end
end
