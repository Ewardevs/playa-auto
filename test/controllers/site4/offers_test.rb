require "test_helper"

module Site4
  class OffersTest < Site4RequestTest
    test "la página de ofertas muestra las promociones vigentes" do
      make_offer(@vehicle)

      get_browser "/v4/ofertas"

      assert_response :success
      assert_match(/RAV4/, response.body)
      assert_match(/1 unidad en promoción/, response.body)
    end

    test "sin promociones la página muestra el estado vacío" do
      get_browser "/v4/ofertas"

      assert_response :success
      assert_match(/No hay promociones vigentes/, response.body)
    end
  end
end
