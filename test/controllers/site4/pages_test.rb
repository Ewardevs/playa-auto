require "test_helper"

module Site4
  class PagesTest < Site4RequestTest
    test "nosotros responde 200 con las cifras de la playa" do
      make_differential

      get_browser "/v4/nosotros"

      assert_response :success
      assert_match(/Playa Test/, response.body)
      assert_match(/1/, response.body)
    end

    test "preguntas frecuentes lista las FAQ con datos estructurados" do
      make_faq

      get_browser "/v4/preguntas-frecuentes"

      assert_response :success
      assert_match(/¿Financian\?/, response.body)
      assert_match(/FAQPage/, response.body)
    end

    test "contacto responde 200 con el formulario y los datos de la playa" do
      get_browser "/v4/contacto"

      assert_response :success
      assert_select 'form[action="/v4/consultas"]', 1
      assert_match(/Av\. Mariscal López 1234/, response.body)
    end
  end
end
