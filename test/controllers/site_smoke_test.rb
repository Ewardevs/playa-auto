require "test_helper"

# Red de seguridad: los cuatro sitios públicos conviven en la misma app. Este
# test solo comprueba que ninguno se rompió al construir Site4 — que cada uno
# sigue sirviendo su propia portada con su propio layout.
class SiteSmokeTest < Site4RequestTest
  test "las cuatro portadas públicas responden 200 con sus layouts" do
    sites = {
      "/v1"  => "site-header",
      "/v2"  => "site2-header",
      "/v3"  => "site3-header",
      "/v4"  => "site4-header"
    }

    sites.each do |path, marker|
      get_browser path

      assert_response :success, "#{path} debería responder 200"
      assert_select "[data-controller='#{marker}']", 1, "#{path} debería usar #{marker}"
    end
  end

  test "el portal de demo enlaza a las cuatro ediciones" do
    get_browser "/"

    assert_response :success
    assert_select "body#site-portal", 1
    assert_select 'meta[name="robots"][content="noindex"]', 1
    assert_select 'a[href="/v1"]', 1
    assert_select 'a[href="/v2"]', 1
    assert_select 'a[href="/v3"]', 1
    assert_select 'a[href="/v4"]', 1
  end

  test "el robots.txt de raíz señala el sitemap de /v1" do
    get_browser "/robots.txt"

    assert_response :success
    assert_match(/Sitemap: http:\/\/www\.example\.com\/v1\/sitemap\.xml/, response.body)
  end

  test "el sitemap de la edición clásica sirve rutas bajo /v1" do
    get_browser "/v1/sitemap.xml"

    assert_response :success
    assert_match(%r{<loc>http://www\.example\.com/v1/}, response.body)
  end

  test "la pantalla de login del admin sigue respondiendo" do
    get_browser "/ingresar"

    assert_response :success
  end
end
