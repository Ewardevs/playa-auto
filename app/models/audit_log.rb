class AuditLog < ApplicationRecord
  # Actions the panel knows how to describe. Anything else still records, it
  # just falls back to a humanised label.
  ACTIONS = %w[
    created updated deleted archived restored duplicated
    status_changed price_changed marked_as_sold
    offer_created offer_updated
    role_changed user_activated user_deactivated password_reset
    settings_updated content_updated
  ].freeze

  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent,       -> { order(created_at: :desc) }
  scope :by_action,    ->(action) { where(action: action) if action.present? }
  scope :by_user,      ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :for_auditable, ->(record) { where(auditable_type: record.class.name, auditable_id: record.id) }

  # Auditing is best-effort: it must never break the operation being audited.
  def self.record!(auditable:, action:, changed_data: {}, label: nil)
    actor = Current.user

    create!(
      user: actor,
      user_name: actor&.name || I18n.t("audit.system_actor"),
      auditable: auditable,
      auditable_label: label.presence || auditable&.to_s,
      action: action.to_s,
      changed_data: serialize_changes(changed_data),
      created_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error(
      "[audit] could not record #{action} on #{auditable.class}##{auditable&.id}: #{e.class}: #{e.message}"
    )
    nil
  end

  # jsonb can't hold BigDecimal/Date objects verbatim, so values are coerced to
  # primitives while keeping the [before, after] shape.
  def self.serialize_changes(changes)
    (changes || {}).each_with_object({}) do |(attribute, (before, after)), result|
      result[attribute.to_s] = [ primitive(before), primitive(after) ]
    end
  end

  def self.primitive(value)
    case value
    when BigDecimal      then value.to_f
    when Date, Time      then value.iso8601
    when ActiveSupport::TimeWithZone then value.iso8601
    else value
    end
  end
  private_class_method :primitive

  def changes_present? = changed_data.present?

  def action_label
    I18n.t("audit.actions.#{action}", default: action.humanize)
  end

  # The name is denormalised at write time so the trail still reads correctly
  # after the account is gone.
  def actor_name
    user_name.presence || user&.display_name || I18n.t("audit.system_actor")
  end

  def tone
    case action
    when "created", "restored", "user_activated" then :ok
    when "deleted", "archived", "user_deactivated" then :danger
    when "status_changed", "marked_as_sold", "role_changed" then :info
    when "price_changed" then :warn
    else :neutral
    end
  end

  # Turns the stored diff into something a person can read:
  #   { "Precio" => ["32.000", "30.500"], "Estado" => ["Disponible", "Reservado"] }
  def readable_changes
    changed_data.to_h do |attribute, (before, after)|
      [ attribute_label(attribute), [ format_value(attribute, before), format_value(attribute, after) ] ]
    end
  end

  private

  def auditable_class
    @auditable_class ||= auditable_type&.safe_constantize
  end

  def attribute_label(attribute)
    auditable_class&.human_attribute_name(attribute) || attribute.humanize
  end

  def format_value(attribute, value)
    return "—" if value.nil? || value == ""

    if auditable_class.respond_to?(:defined_enums) && auditable_class.defined_enums.key?(attribute)
      return auditable_class.human_enum_name(attribute, value)
    end

    case value
    when Numeric then ActiveSupport::NumberHelper.number_to_delimited(value, delimiter: ".", separator: ",")
    when true then I18n.t("admin.states.active")
    when false then I18n.t("admin.states.inactive")
    else value.to_s
    end
  end
end
