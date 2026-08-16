# Request-scoped state. Keeps the audit trail from having to thread the acting
# user through every service and model call.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :setting
end
