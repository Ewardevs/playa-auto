module Vehicles
  # The only door between the inventory and the public site.
  #
  # Every public query starts here, and what it returns is decided exclusively
  # by the business: archived and hidden stock never leaves the panel, and
  # whether sold vehicles stay visible is a setting, never a URL parameter.
  # Nothing a visitor can type widens this scope.
  class Public
    ALWAYS_VISIBLE = %w[available reserved].freeze

    def self.call(...) = new(...).relation

    def initialize(setting: Setting.current)
      @setting = setting
    end

    def relation
      Vehicle.kept.published.where(status: visible_statuses)
    end

    # Sold stock is shown only if the playa asked for it, and always labelled as
    # sold — see Site::VehicleCardComponent.
    def visible_statuses
      statuses = ALWAYS_VISIBLE.dup
      statuses << "sold" if @setting.show_sold_vehicles?
      statuses
    end
  end
end
