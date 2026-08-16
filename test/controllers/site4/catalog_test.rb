require "test_helper"

module Site4
  class CatalogTest < Site4RequestTest
    test "el catálogo lista las unidades publicadas" do
      get_browser "/v4/vehiculos"

      assert_response :success
      assert_match(/RAV4/, response.body)
      assert_match(/1 vehículo/, response.body)
    end

    test "el catálogo muestra contadores de faceta honestos" do
      other_brand  = make_brand("Volkswagen")
      other_model  = make_model(other_brand, "Golf")
      make_vehicle(brand: other_brand, category: @category, model: other_model)

      get_browser "/v4/vehiculos"

      assert_response :success
      assert_match(/Toyota · 1/, response.body)
      assert_match(/Volkswagen · 1/, response.body)
    end

    test "filtrar por marca muestra solo esa marca" do
      other_brand = make_brand("Volkswagen")
      other_model = make_model(other_brand, "Golf")
      make_vehicle(brand: other_brand, category: @category, model: other_model)

      get_browser "/v4/vehiculos", params: { marca: other_brand.slug }

      assert_response :success
      assert_match(/Golf/, response.body)
      assert_no_match(/RAV4/, response.body)
      assert_match(/Volkswagen · 1/, response.body)
    end

    test "la búsqueda por texto filtra el catálogo" do
      get_browser "/v4/vehiculos", params: { q: "toyota" }

      assert_response :success
      assert_match(/RAV4/, response.body)
    end

    test "un filtro que no deja resultados muestra el estado vacío" do
      get_browser "/v4/vehiculos", params: { q: "no-existe" }

      assert_response :success
      assert_match(/Ningún vehículo coincide/, response.body)
      assert_match(/name="robots" content="noindex/, response.body)
    end

    test "los filtros activos se pueden quitar con un enlace" do
      get_browser "/v4/vehiculos", params: { marca: @brand.slug }

      assert_response :success
      assert_match(/Toyota/, response.body)
      assert_match(%r{href="/v4/vehiculos"}, response.body)
    end

    test "ordenar por menor precio respeta el orden" do
      other_brand = make_brand("Volkswagen")
      other_model = make_model(other_brand, "Golf")
      make_vehicle(brand: other_brand, category: @category, model: other_model,
                   price: 15_000_000)

      get_browser "/v4/vehiculos", params: { orden: "precio-asc" }

      assert_response :success
      assert_match(/Golf/, response.body)
    end
  end
end
