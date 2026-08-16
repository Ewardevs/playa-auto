module Vehicles
  # Moves a vehicle between states and records the move as its own audit entry,
  # so "who marked this sold, and when" is answerable later.
  #
  # Selling a vehicle also closes its open inquiries: they are no longer leads.
  class ChangeStatus
    class InvalidStatus < StandardError; end

    def initialize(vehicle, status:)
      @vehicle = vehicle
      @status  = status.to_s
    end

    def call
      raise InvalidStatus, @status unless Vehicle.statuses.key?(@status)

      previous = @vehicle.status
      return @vehicle if previous == @status

      Vehicle.transaction do
        @vehicle.update!(status: @status)
        close_open_inquiries if @status == "sold"
      end

      @vehicle.log_audit(action_for(previous), changes: { "status" => [ previous, @status ] })
      @vehicle
    end

    private

    def action_for(previous)
      @status == "sold" && previous != "sold" ? :marked_as_sold : :status_changed
    end

    def close_open_inquiries
      @vehicle.inquiries.where.not(status: %i[sold closed])
              .update_all(status: Inquiry.statuses[:closed], closed_at: Time.current, updated_at: Time.current)
    end
  end
end
