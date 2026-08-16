require "test_helper"

module Site4
  class InquiriesTest < Site4RequestTest
    test "una consulta válida crea el Inquiry y redirige a la ficha" do
      assert_difference -> { Inquiry.count }, 1 do
        post_browser "/v4/consultas", params: {
          inquiry: { name: "Cliente Test", phone: "0981999000",
                     email: "cliente@test.com", message: "¿Está disponible?",
                     vehicle_slug: @vehicle.slug }
        }
      end

      assert_redirected_to "/v4/vehiculos/#{@vehicle.slug}"
      inquiry = Inquiry.last
      assert_equal "Cliente Test", inquiry.name
      assert_equal @vehicle, inquiry.vehicle
    end

    test "el honeypot descarta la consulta sin crear nada" do
      assert_no_difference -> { Inquiry.count } do
        post_browser "/v4/consultas", params: {
          website: "http://spam.example.com",
          inquiry: { name: "Bot", phone: "0981000000", message: "hola" }
        }
      end

      assert_redirected_to "/v4/contacto"
    end

    test "una consulta sin nombre ni teléfono no crea nada y re-renderiza" do
      assert_no_difference -> { Inquiry.count } do
        post_browser "/v4/consultas", params: {
          inquiry: { name: "", phone: "" }
        }
      end

      assert_response :unprocessable_content
      assert_match(/Revisá los datos del formulario/, response.body)
    end
  end
end
