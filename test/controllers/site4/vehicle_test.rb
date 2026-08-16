require "test_helper"

module Site4
  class VehicleTest < Site4RequestTest
    test "la ficha responde 200 con datos estructurados" do
      get_browser "/v4/vehiculos/#{@vehicle.slug}"

      assert_response :success
      assert_match(/RAV4/, response.body)
      assert_match(/"@type": ?"Car"/, response.body)
      assert_match(/"@type": ?"Offer"/, response.body)
    end

    test "la ficha incluye el formulario de consulta" do
      get_browser "/v4/vehiculos/#{@vehicle.slug}"

      assert_response :success
      assert_select 'form[action="/v4/consultas"]', 1
      assert_select 'input[name="website"]', 1
    end

    test "una unidad no publicada es 404" do
      hidden = make_vehicle(brand: @brand, category: @category, model: @model,
                            status: "hidden")

      get_browser "/v4/vehiculos/#{hidden.slug}"

      assert_response :not_found
    end

    test "una unidad archivada es 404" do
      archived = make_vehicle(brand: @brand, category: @category, model: @model)
      archived.discard

      get_browser "/v4/vehiculos/#{archived.slug}"

      assert_response :not_found
    end

    test "una unidad sin publicar es 404" do
      draft = make_vehicle(brand: @brand, category: @category, model: @model)
      draft.update!(published_at: nil)

      get_browser "/v4/vehiculos/#{draft.slug}"

      assert_response :not_found
    end

    test "una unidad vendida no se ve si show_sold_vehicles está apagado" do
      sold = make_vehicle(brand: @brand, category: @category, model: @model,
                          status: "sold")

      get_browser "/v4/vehiculos/#{sold.slug}"

      assert_response :not_found
    end

    test "una unidad vendida se ve etiquetada si show_sold_vehicles está encendido" do
      Setting.current.update!(show_sold_vehicles: true)
      sold = make_vehicle(brand: @brand, category: @category, model: @model,
                          status: "sold")

      get_browser "/v4/vehiculos/#{sold.slug}"

      assert_response :success
      assert_match(/ya fue vendida/, response.body)
    end

    test "el botón de WhatsApp contabiliza el clic" do
      @vehicle.update!(whatsapp_clicks_count: 0)

      assert_difference -> { @vehicle.reload.whatsapp_clicks_count } do
        post_browser "/v4/vehiculos/#{@vehicle.slug}/whatsapp_click"
      end
      assert_response :no_content
    end
  end
end
