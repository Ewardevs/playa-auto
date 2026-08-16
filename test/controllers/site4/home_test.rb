require "test_helper"

module Site4
  class HomeTest < Site4RequestTest
    test "la portada responde 200 con el layout de Site4" do
      get_browser "/v4"

      assert_response :success
      assert_select '[data-controller="site4-header"]', 1
      assert_select "main#contenido"
    end

    test "la portada no filtra fragmentos de otros sitios" do
      get_browser "/v4"

      assert_response :success
      assert_no_match(/site3-/, response.body)
      assert_no_match(/site2-/, response.body)
    end

    test "la portada publica los datos estructurados de concesionaria" do
      get_browser "/v4"

      assert_response :success
      assert_match(/application\/ld\+json/, response.body)
      assert_match(/AutoDealer/, response.body)
      assert_match(/Playa Test/, response.body)
    end

    test "muestra la unidad destacada del catálogo" do
      @vehicle.update!(featured: true)

      get_browser "/v4"

      assert_response :success
      assert_match(/RAV4/, response.body)
    end

    test "modo evaluación: la portada sale con noindex" do
      get_browser "/v4"

      assert_response :success
      assert_match(/name="robots" content="noindex/, response.body)
    end
  end
end
