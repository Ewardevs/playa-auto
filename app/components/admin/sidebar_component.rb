# frozen_string_literal: true

module Admin
  # The navigation rail. Entries are filtered through Pundit, so a user never
  # sees a section they cannot open — the menu and the backend agree.
  #
  # Collapses to an icon rail on desktop and becomes an off-canvas drawer on
  # small screens; both states are driven by the `sidebar` Stimulus controller.
  class SidebarComponent < ApplicationComponent
    Item = Struct.new(:label, :path, :icon, :match, keyword_init: true)

    def initialize(current_path:)
      @current_path = current_path
    end

    private

    attr_reader :current_path

    def sections
      [
        { items: [ dashboard_item ].compact },
        { label: t("admin.nav.groups.inventory"), items: inventory_items },
        { label: t("admin.nav.groups.sales"), items: sales_items },
        { label: t("admin.nav.groups.site"), items: site_items },
        { label: t("admin.nav.groups.system"), items: system_items }
      ].reject { |section| section[:items].empty? }
    end

    def dashboard_item
      Item.new(label: t("admin.nav.dashboard"), path: helpers.admin_root_path, icon: :gauge, match: :exact)
    end

    def inventory_items
      [
        (item(t("admin.nav.vehicles"), helpers.admin_vehicles_path, :car) if allowed?(Vehicle, :index?)),
        (item(t("admin.nav.brands"), helpers.admin_brands_path, :tag) if allowed?(Brand, :index?)),
        (item(t("admin.nav.models"), helpers.admin_vehicle_models_path, :layers) if allowed?(VehicleModel, :index?)),
        (item(t("admin.nav.categories"), helpers.admin_categories_path, :grid) if allowed?(Category, :index?))
      ].compact
    end

    def sales_items
      [
        (item(t("admin.nav.offers"), helpers.admin_offers_path, :percent) if allowed?(Offer, :index?)),
        (item(t("admin.nav.inquiries"), helpers.admin_inquiries_path, :inbox) if allowed?(Inquiry, :index?))
      ].compact
    end

    def site_items
      [
        (item(t("admin.nav.content"), helpers.admin_content_path, :file_text) if allowed?(SiteContent.new, :show?)),
        (item(t("admin.nav.faqs"), helpers.admin_faqs_path, :info) if allowed?(Faq, :index?)),
        (item(t("admin.nav.differentials"), helpers.admin_differentials_path, :star) if allowed?(Differential, :index?))
      ].compact
    end

    def system_items
      [
        (item(t("admin.nav.users"), helpers.admin_users_path, :users) if allowed?(User, :index?)),
        (item(t("admin.nav.audit"), helpers.admin_audit_logs_path, :history) if allowed?(AuditLog, :index?)),
        (item(t("admin.nav.settings"), helpers.admin_settings_path, :settings) if allowed?(Setting.new, :show?))
      ].compact
    end

    def item(label, path, icon)
      Item.new(label: label, path: path, icon: icon, match: :prefix)
    end

    def allowed?(record, query)
      helpers.policy(record).public_send(query)
    rescue Pundit::NotDefinedError, Pundit::NotAuthorizedError
      false
    end

    def active?(entry)
      if entry.match == :exact
        current_path == entry.path
      else
        current_path.start_with?(entry.path)
      end
    end

    def link_classes(entry)
      base = "group relative flex items-center gap-3 h-9.5 px-2.5 rounded-md text-sm transition-colors"

      if active?(entry)
        "#{base} bg-rail-2 text-rail-ink font-medium"
      else
        "#{base} text-rail-muted hover:text-rail-ink hover:bg-rail-2/60"
      end
    end
  end
end
