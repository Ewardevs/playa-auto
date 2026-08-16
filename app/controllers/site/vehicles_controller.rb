module Site
  class VehiclesController < BaseController
    include Pagy::Method

    PER_PAGE = 12

    def index
      @search = Vehicles::PublicSearch.new(params: params)
      @pagy, @vehicles = pagy(@search.results, limit: PER_PAGE)

      # Materializadas acá: el componente de filtros se renderiza dos veces (barra
      # lateral en escritorio y cajón en móvil) y una relación perezosa se
      # consultaría una vez por render.
      @brands     = Brand.active.ordered.to_a
      @categories = Category.active.ordered.to_a
      @models     = models_for_selected_brand.to_a

      breadcrumb t("site.nav.vehicles")
      set_index_seo
      public_cache
    end

    def show
      @vehicle = find_public_vehicle
      @related = Vehicles::Related.call(@vehicle, limit: 4)
      @inquiry = Inquiry.new(vehicle: @vehicle)

      # Cheap counter bump: no validations, no callbacks, one UPDATE.
      @vehicle.register_view!

      breadcrumb t("site.nav.vehicles"), site_vehicles_path
      breadcrumb @vehicle.brand.name, site_vehicles_path(marca: @vehicle.brand.slug)
      breadcrumb @vehicle.display_name

      set_show_seo
    end

    # Records that a visitor opened WhatsApp from this vehicle, so the admin can
    # report on the channel that actually converts. Fire-and-forget: the button
    # is a normal link and never waits for this.
    def whatsapp_click
      vehicle = find_public_vehicle
      Vehicle.where(id: vehicle.id).update_all("whatsapp_clicks_count = whatsapp_clicks_count + 1")

      head :no_content
    end

    private

    # `find_by!` against the public scope, so an unlisted vehicle is a 404 for
    # the outside world rather than a page that leaks it exists.
    def find_public_vehicle
      Vehicles::Public.call.with_associations.find_by!(slug: params[:slug])
    end

    def models_for_selected_brand
      brand = @search.selected_brand
      return VehicleModel.none unless brand

      VehicleModel.active.where(brand: brand).order(:name)
    end

    def set_index_seo
      seo.title = if @search.selected_brand
                    t("site.vehicles.seo.brand_title", brand: @search.selected_brand.name)
      elsif @search.selected_category
                    t("site.vehicles.seo.category_title", category: @search.selected_category.name)
      else
                    t("site.vehicles.seo.title")
      end

      seo.description = t("site.vehicles.seo.description",
                          count: @pagy.count, company: current_setting.company_name)

      # A filtered or paginated list is a view of the catalogue, not a new page:
      # it points its canonical at /vehiculos and stays out of the index.
      seo.noindex! if @search.filtered? || @pagy.page > 1
    end

    def set_show_seo
      seo.title       = t("site.vehicles.seo.show_title",
                          vehicle: @vehicle.display_name, price: helpers.money(@vehicle.current_price))
      seo.description = vehicle_description
      seo.og_type     = "product"
      seo.image_url   = main_image_url
    end

    def vehicle_description
      @vehicle.meta_description.presence ||
        t("site.vehicles.seo.show_description",
          vehicle: @vehicle.display_name,
          mileage: helpers.mileage(@vehicle.mileage),
          fuel: Vehicle.human_enum_name(:fuel_type, @vehicle.fuel_type),
          transmission: Vehicle.human_enum_name(:transmission, @vehicle.transmission),
          company: current_setting.company_name)
    end

    def main_image_url
      image = @vehicle.main_image
      return unless image&.file&.attached?

      url_for(image.file.variant(:large))
    end
  end
end
