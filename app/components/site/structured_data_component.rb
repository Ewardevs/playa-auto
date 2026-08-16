# frozen_string_literal: true

module Site
  # JSON-LD for search engines.
  #
  # Every value is read from the domain — nothing here is invented, and a field
  # the playa has not filled in is simply omitted rather than guessed.
  class StructuredDataComponent < ApplicationComponent
    def initialize(vehicle: nil, faqs: [], breadcrumbs: [], request_url: nil)
      @vehicle     = vehicle
      @faqs        = Array(faqs)
      @breadcrumbs = Array(breadcrumbs)
      @request_url = request_url
    end

    def call
      graphs = [ dealer, vehicle_graph, faq_graph, breadcrumb_graph ].compact
      return "".html_safe if graphs.empty?

      safe_join(graphs.map { |graph| json_ld(graph) })
    end

    private

    attr_reader :vehicle, :faqs, :breadcrumbs

    def json_ld(payload)
      # json_escape turns <, > and & into <, > and &, so a
      # "</script>" inside a description cannot break out of the tag.
      tag.script(
        raw(ERB::Util.json_escape(payload.to_json)),
        type: "application/ld+json"
      )
    end

    def setting = current_setting

    def dealer
      {
        "@context" => "https://schema.org",
        "@type" => "AutoDealer",
        "name" => setting.company_name,
        "url" => helpers.site_root_url,
        "telephone" => setting.phone.presence,
        "email" => setting.email.presence,
        "image" => logo_url,
        "address" => address,
        "openingHours" => setting.opening_hours_lines.presence,
        "sameAs" => setting.social_links.values.presence,
        "hasMap" => setting.google_maps_url.presence
      }.compact
    end

    def address
      return if setting.address.blank?

      { "@type" => "PostalAddress", "streetAddress" => setting.address }
    end

    def logo_url
      return unless setting.logo.attached?

      helpers.url_for(setting.logo)
    end

    def vehicle_graph
      return if vehicle.blank?

      {
        "@context" => "https://schema.org",
        "@type" => "Car",
        "name" => vehicle.display_name,
        "url" => helpers.site_vehicle_url(vehicle),
        "sku" => vehicle.code,
        "image" => vehicle_images.presence,
        "description" => vehicle.description.presence,
        "brand" => { "@type" => "Brand", "name" => vehicle.brand.name },
        "model" => vehicle.vehicle_model.name,
        "vehicleModelDate" => vehicle.year.to_s,
        "productionDate" => vehicle.year.to_s,
        "color" => vehicle.color.presence,
        "vehicleTransmission" => Vehicle.human_enum_name(:transmission, vehicle.transmission),
        "fuelType" => Vehicle.human_enum_name(:fuel_type, vehicle.fuel_type),
        "mileageFromOdometer" => {
          "@type" => "QuantitativeValue", "value" => vehicle.mileage, "unitCode" => "KMT"
        },
        "offers" => vehicle_offer
      }.compact
    end

    def vehicle_offer
      {
        "@type" => "Offer",
        "price" => vehicle.current_price.to_i,
        "priceCurrency" => setting.currency,
        "availability" => availability,
        "url" => helpers.site_vehicle_url(vehicle),
        "priceValidUntil" => vehicle.running_offer&.ends_on&.iso8601,
        "seller" => { "@type" => "AutoDealer", "name" => setting.company_name }
      }.compact
    end

    def availability
      case vehicle.status
      when "available" then "https://schema.org/InStock"
      when "reserved"  then "https://schema.org/LimitedAvailability"
      else "https://schema.org/SoldOut"
      end
    end

    def vehicle_images
      vehicle.images.select { |image| image.file.attached? }
             .first(6)
             .map { |image| helpers.url_for(image.file.variant(:large)) }
    end

    def faq_graph
      return if faqs.empty?

      {
        "@context" => "https://schema.org",
        "@type" => "FAQPage",
        "mainEntity" => faqs.map do |faq|
          {
            "@type" => "Question",
            "name" => faq.question,
            "acceptedAnswer" => { "@type" => "Answer", "text" => faq.answer }
          }
        end
      }
    end

    def breadcrumb_graph
      return if breadcrumbs.empty?

      items = [ [ t("site.nav.home"), helpers.site_root_url ] ] + breadcrumbs

      {
        "@context" => "https://schema.org",
        "@type" => "BreadcrumbList",
        "itemListElement" => items.each_with_index.map do |(label, path), index|
          {
            "@type" => "ListItem",
            "position" => index + 1,
            "name" => label,
            "item" => absolute(path)
          }.compact
        end
      }
    end

    def absolute(path)
      return if path.blank?
      return path if path.start_with?("http")

      URI.join(helpers.site_root_url, path).to_s
    rescue URI::InvalidURIError
      nil
    end
  end
end
