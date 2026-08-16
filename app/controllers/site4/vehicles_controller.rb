module Site4
  class VehiclesController < BaseController
    include Pagy::Method

    PER_PAGE = 12

    def index
      @search = Vehicles::PublicSearch.new(params: params)
      @pagy, @vehicles = pagy(@search.results, limit: PER_PAGE)

      load_filter_options
      load_facets
      load_active_filters

      breadcrumb t("site4.nav.vehicles")
      set_index_seo
      public_cache
    end

    def show
      @vehicle = find_public_vehicle
      @related = Vehicles::Related.call(@vehicle, limit: 3)
      @inquiry = Inquiry.new(vehicle: @vehicle)

      @vehicle.register_view!

      breadcrumb t("site4.nav.vehicles"), site4_vehicles_path
      breadcrumb @vehicle.brand.name, site4_vehicles_path(marca: @vehicle.brand.slug)
      breadcrumb @vehicle.display_name

      set_show_seo
    end

    def whatsapp_click
      vehicle = find_public_vehicle
      Vehicle.where(id: vehicle.id).update_all("whatsapp_clicks_count = whatsapp_clicks_count + 1")

      head :no_content
    end

    private

    # Contra el alcance público: una unidad no publicada es un 404, no una
    # página que revele que existe.
    def find_public_vehicle
      Vehicles::Public.call.with_associations.find_by!(slug: params[:slug])
    end

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

    # Contadores de facetas. Cada cuenta responde a "cuántos resultados habría
    # si eligiera esta opción" — se calcula sobre el catálogo público con TODOS
    # los filtros actuales menos el de la propia faceta, que es la semántica
    # honesta de una faceta.
    def load_facets
      @brand_counts         = facet_relation(:marca).group(:brand_id).count
      @category_counts      = facet_relation(:categoria).group(:category_id).count
      @fuel_counts          = facet_relation(:combustible).group(:fuel_type).count
      @transmission_counts  = facet_relation(:transmision).group(:transmission).count
      @model_counts         = @search.selected_brand ? facet_relation(:modelo).group(:vehicle_model_id).count : {}
    end

    def facet_relation(except)
      scoped = params.to_unsafe_h.except("controller", "action", "page", except.to_s)
      Vehicles::PublicSearch.new(params: scoped).results.reorder(nil)
    end

    # Las fichas de filtros activos, con su enlace para quitarlos.
    def load_active_filters
      @active_filters = []
      current_params  = params.to_unsafe_h

      if current_params["q"].present?
        @active_filters << [ t("site4.filters.text"), remove_path(:q) ]
      end

      if (brand = @search.selected_brand)
        @active_filters << [ brand.name, remove_path(:marca) ]
      end

      if current_params["modelo"].present?
        model = VehicleModel.active.find_by(slug: current_params["modelo"])
        @active_filters << [ model&.name.presence || current_params["modelo"], remove_path(:modelo) ]
      end

      if (category = @search.selected_category)
        @active_filters << [ category.name, remove_path(:categoria) ]
      end

      price_label = range_label(:precio_min, :precio_max, currency: true)
      @active_filters << [ price_label, remove_path(:precio_min, :precio_max) ] if price_label

      year_label = range_label(:anio_min, :anio_max)
      @active_filters << [ year_label, remove_path(:anio_min, :anio_max) ] if year_label

      if current_params["km_max"].present?
        @active_filters << [ t("site4.vehicles.spec_mileage"),
                             remove_path(:km_max) ]
      end

      fuel = current_params["combustible"]
      if fuel.present? && Vehicle.fuel_types.key?(fuel)
        @active_filters << [ Vehicle.human_enum_name(:fuel_type, fuel), remove_path(:combustible) ]
      end

      transmission = current_params["transmision"]
      if transmission.present? && Vehicle.transmissions.key?(transmission)
        @active_filters << [ Vehicle.human_enum_name(:transmission, transmission), remove_path(:transmision) ]
      end

      status = current_params["estado"]
      if status.present? && Vehicle.statuses.key?(status)
        @active_filters << [ Vehicle.human_enum_name(:status, status), remove_path(:estado) ]
      end
    end

    def range_label(min_key, max_key, currency: false)
      min_value = params[min_key].presence
      max_value = params[max_key].presence
      return if min_value.blank? && max_value.blank?

      format_value = ->(value) { currency ? helpers.money(value.to_i) : value.to_i.to_s }

      if min_value.present? && max_value.present?
        "#{format_value.call(min_value)} – #{format_value.call(max_value)}"
      elsif min_value.present?
        "Desde #{format_value.call(min_value)}"
      else
        "Hasta #{format_value.call(max_value)}"
      end
    end

    def remove_path(*keys)
      scoped = params.to_unsafe_h.except("controller", "action", "page", *keys.map(&:to_s))
      site4_vehicles_path(scoped)
    end

    def set_index_seo
      seo.title = if @search.selected_brand
                    t("site4.vehicles.seo.brand_title", brand: @search.selected_brand.name)
      elsif @search.selected_category
                    t("site4.vehicles.seo.category_title", category: @search.selected_category.name)
      else
                    t("site4.vehicles.seo.title")
      end

      seo.description = t("site4.vehicles.seo.description",
                          count: @pagy.count, company: current_setting.company_name)

      seo.noindex! if @search.filtered? || @pagy.page > 1
    end

    def set_show_seo
      seo.title       = t("site4.vehicles.seo.show_title",
                          vehicle: @vehicle.display_name, price: helpers.money(@vehicle.current_price))
      seo.description = vehicle_description
      seo.og_type     = "product"
      seo.image_url   = main_image_url
    end

    def vehicle_description
      @vehicle.meta_description.presence ||
        t("site4.vehicles.seo.show_description",
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
