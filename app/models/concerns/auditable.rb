# Records who changed what, and when, for the entities the business cares about.
# Declared per model with `audits`:
#
#   class Vehicle < ApplicationRecord
#     include Auditable
#     audits :price, :status, :featured
#   end
#
# Only the declared attributes are diffed, which keeps the trail readable and
# the write small. Logging never raises: a failure to audit must not roll back
# the operation the user actually asked for.
module Auditable
  extend ActiveSupport::Concern

  included do
    class_attribute :audited_attributes, default: [], instance_writer: false

    has_many :audit_logs, as: :auditable, dependent: :nullify

    after_create_commit  { log_audit(:created,  changes: {}) }
    after_update_commit  { log_audit(:updated) }
    after_destroy_commit { log_audit(:deleted,  changes: {}) }
  end

  class_methods do
    def audits(*attributes)
      self.audited_attributes = attributes.map(&:to_s)
    end
  end

  # Public so service objects can record domain events that aren't a plain
  # attribute diff, e.g. `vehicle.log_audit(:duplicated)`.
  def log_audit(action, changes: nil)
    action  = resolve_action(action)
    changes ||= audited_diff

    return if action.to_s == "updated" && changes.blank?

    AuditLog.record!(auditable: self, action: action, changed_data: changes, label: audit_label)
  end

  def audit_label
    respond_to?(:display_name) ? display_name : "#{self.class.model_name.human} ##{id}"
  end

  private

  # Archiving is technically an update, but reads far better in the trail as its
  # own action.
  def resolve_action(action)
    return action unless action.to_s == "updated"
    return action unless respond_to?(:discarded_at) && saved_change_to_discarded_at?

    discarded? ? :archived : :restored
  end

  def audited_diff
    saved_changes.slice(*audited_attributes)
  end
end
