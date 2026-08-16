module Inquiries
  # Moves an inquiry through the sales pipeline, stamping the timestamps the
  # team reports on and recording the move in the audit trail.
  class UpdateStatus
    class InvalidStatus < StandardError; end

    def initialize(inquiry, status:, user: Current.user)
      @inquiry = inquiry
      @status  = status.to_s
      @user    = user
    end

    def call
      raise InvalidStatus, @status unless Inquiry.statuses.key?(@status)

      previous = @inquiry.status
      return @inquiry if previous == @status

      @inquiry.status = @status
      @inquiry.contacted_at ||= Time.current if contacted?
      @inquiry.closed_at = closed? ? Time.current : nil
      # An inquiry being worked belongs to whoever is working it.
      @inquiry.user ||= @user if previous == "new_lead"

      @inquiry.save!
      @inquiry.log_audit(:status_changed, changes: { "status" => [ previous, @status ] })
      @inquiry
    end

    private

    def contacted? = @status != "new_lead"

    def closed? = %w[sold closed].include?(@status)
  end
end
