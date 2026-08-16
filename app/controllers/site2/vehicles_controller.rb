module Site2
  class VehiclesController < BaseController
    include Pagy::Method

    PER_PAGE = 12

    def index
      @search = Vehicles::PublicSearch.new(params: params)
      @pagy, @vehicles = pagy(@search.results, limit: PER_PAGE)

      load_filter_options

      breadcrumb t("site2.nav.vehicles")
      set_index_seo
      public_cache
    end

    def show
      @vehicle = find_public_vehicle
      @related = Vehicles::Related.call(@vehicle, limit: 4)
      @inquiry = Inquiry.new(vehicle: @vehicle)

      @vehicle.register_view!

      breadcrumb t("site2.nav.vehicles"), site2_vehicles_path
      breadcrumb @vehicle.brand.name, site2_vehicles_path(marca: @vehicle.brand.slug)
      breadcrumb @vehicle.display_name

      set_show_seo
    end

    # Deja constancia de que alguien abrió WhatsApp desde esta unidad, para que
    # el panel pueda medir el canal que realmente convierte. El botón es un
    # enlace normal y nunca espera por esto.
    def whatsapp_click
      vehicle = find_public_vehicle
      Vehicle.where(id: vehicle.id).update_all("whatsapp_clicks_count = whatsapp_clicks_count + 1")

      head :no_content
    end

    private

    # `find_by!` contra el alcance público: una unidad no publicada es un 404
    # para el mundo exterior, no una página que revele que existe.
    def find_public_vehicle
      Vehicles::Public.call.with_associations.find_by!(slug: params[:slug])
    end

    # Materializadas acá: la barra de filtros se renderiza una vez, pero el
    # resumen de filtros activos vuelve a leer las mismas colecciones.
    def load_filter_options
      @brands     = Brand.active.ordered.to_a
      @categories = Category.active.ordered.to_a
      @models     = models_for_selected_brand
    end

    def models_for_selected_brand
      brand = @search.selected_brand
      return [] unless brand

      VehicleModel.active.where(brand: brand).order(:name).to_a
    end

    def set_index_seo
      seo.title = if @search.selected_brand
                    t("site2.vehicles.seo.brand_title", brand: @search.selected_brand.name)
      elsif @search.selected_category
                    t("site2.vehicles.seo.category_title", category: @search.selected_category.name)
      else
                    t("site2.vehicles.seo.title")
      end

      seo.description = t("site2.vehicles.seo.description",
                          count: @pagy.count, company: current_setting.company_name)

      # Un listado filtrado o paginado es una vista del catálogo, no una página
      # nueva: apunta su canónico a /v2/vehiculos y se queda fuera del índice.
      seo.noindex! if @search.filtered? || @pagy.page > 1
    end

    def set_show_seo
      seo.title       = t("site2.vehicles.seo.show_title",
                          vehicle: @vehicle.display_name, price: helpers.money(@vehicle.current_price))
      seo.description = vehicle_description
      seo.og_type     = "product"
      seo.image_url   = main_image_url
    end

    def vehicle_description
      @vehicle.meta_description.presence ||
        t("site2.vehicles.seo.show_description",
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
