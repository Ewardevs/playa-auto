module Inquiries
  # Filters the inquiry list: free text over name, phone and email, plus status,
  # vehicle, seller and a date range.
  class Filter
    def initialize(scope: Inquiry.all, params: {})
      @scope  = scope
      @params = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
    end

    def results
      relation = scope
      relation = by_text(relation)
      relation = by_status(relation)
      relation = by_vehicle(relation)
      relation = by_seller(relation)
      relation = by_dates(relation)
      relation.order(created_at: :desc)
    end

    private

    attr_reader :scope, :params

    def param(key) = params[key.to_s].presence

    def by_text(relation)
      term = param(:q)
      return relation if term.blank?

      pattern = "%#{Inquiry.sanitize_sql_like(term)}%"
      relation.where(
        "inquiries.name ILIKE :q OR inquiries.phone ILIKE :q OR inquiries.email ILIKE :q",
        q: pattern
      )
    end

    def by_status(relation)
      value = param(:status)
      return relation unless value && Inquiry.statuses.key?(value)

      relation.where(status: value)
    end

    def by_vehicle(relation)
      value = param(:vehicle_id)
      value ? relation.where(vehicle_id: value) : relation
    end

    def by_seller(relation)
      value = param(:user_id)
      return relation if value.blank?
      return relation.where(user_id: nil) if value == "none"

      relation.where(user_id: value)
    end

    def by_dates(relation)
      relation = relation.where(created_at: Date.parse(param(:from)).beginning_of_day..) if param(:from)
      relation = relation.where(created_at: ..Date.parse(param(:to)).end_of_day) if param(:to)
      relation
    rescue Date::Error
      # A malformed date in the query string narrows nothing rather than erroring.
      relation
    end
  end
end
