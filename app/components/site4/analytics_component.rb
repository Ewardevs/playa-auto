# frozen_string_literal: true

module Site4
  # Analytics de terceros, en exactamente un lugar.
  #
  # Los sitios 2 y 3 reutilizan el componente de Site1; Site4 trae el suyo para
  # no tocar ningún componente compartido. La regla es idéntica: nada se inyecta
  # salvo que la playa haya configurado un id en Configuración.
  class AnalyticsComponent < ApplicationComponent
    def render?
      Rails.env.production? && current_setting.analytics?
    end

    private

    def ga_id  = current_setting.google_analytics_id.presence
    def gtm_id = current_setting.google_tag_manager_id.presence
    def pixel_id = current_setting.meta_pixel_id.presence

    # Ids se vuelcan en JavaScript: solo los caracteres que estos proveedores
    # usan de verdad pueden pasar.
    def safe(id) = id.to_s.gsub(/[^A-Za-z0-9\-_]/, "")
  end
end
