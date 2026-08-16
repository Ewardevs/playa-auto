module Dashboard
  # Everything the dashboard shows, gathered in one place.
  #
  # Counts come from a single grouped query rather than one COUNT per card, and
  # every list is preloaded, so the whole screen costs a handful of queries no
  # matter how much stock the playa has.
  #
  # Panels the user may not see are simply not queried — the dashboard obeys the
  # same policies as the modules behind it.
  class Overview
    LIST_SIZE = 6
    CHART_MONTHS = 6
    RECENT_DAYS = 30

    def initialize(user:, now: Time.current)
      @user = user
      @now  = now
    end

    # ── Vehicles ─────────────────────────────────────────────────────────────

    def vehicles? = policy(Vehicle).index?

    def status_counts
      @status_counts ||= vehicles? ? base_vehicles.group(:status).count : {}
    end

    def total_vehicles   = @total_vehicles ||= status_counts.values.sum
    def available_count  = status_counts["available"].to_i
    def reserved_count   = status_counts["reserved"].to_i
    def sold_count       = status_counts["sold"].to_i
    def hidden_count     = status_counts["hidden"].to_i

    # "Publicados" means visible stock: everything except hidden and archived.
    def published_count = total_vehicles - hidden_count

    def featured_count
      @featured_count ||= vehicles? ? base_vehicles.featured.count : 0
    end

    def recent_vehicles
      @recent_vehicles ||= return_empty_unless(vehicles?) do
        base_vehicles.with_associations.ordered.limit(LIST_SIZE).to_a
      end
    end

    def most_viewed
      @most_viewed ||= return_empty_unless(vehicles?) do
        base_vehicles.where("views_count > 0").with_associations.most_viewed.limit(LIST_SIZE).to_a
      end
    end

    def most_inquired
      @most_inquired ||= return_empty_unless(vehicles?) do
        base_vehicles.where("inquiries_count > 0").with_associations.most_inquired.limit(LIST_SIZE).to_a
      end
    end

    def inventory_segments
      [
        [ Vehicle.human_enum_name(:status, :available), available_count, :ok ],
        [ Vehicle.human_enum_name(:status, :reserved),  reserved_count,  :warn ],
        [ Vehicle.human_enum_name(:status, :sold),      sold_count,      :info ],
        [ Vehicle.human_enum_name(:status, :hidden),    hidden_count,    :off ]
      ]
    end

    # ── Inquiries ────────────────────────────────────────────────────────────

    def inquiries? = policy(Inquiry).index?

    def new_inquiries_count
      @new_inquiries_count ||= inquiries? ? Inquiry.new_lead.count : 0
    end

    def month_inquiries_count
      @month_inquiries_count ||= inquiries? ? Inquiry.where(created_at: @now.all_month).count : 0
    end

    def latest_inquiries
      @latest_inquiries ||= return_empty_unless(inquiries?) do
        Inquiry.includes(vehicle: [ :brand, :vehicle_model ]).order(created_at: :desc).limit(LIST_SIZE).to_a
      end
    end

    # [["mar", 4], ["abr", 9], …] — one grouped query, zero-filled so empty
    # months still occupy their slot on the chart.
    def inquiries_by_month
      @inquiries_by_month ||= begin
        return [] unless inquiries?

        first_month = (@now - (CHART_MONTHS - 1).months).beginning_of_month
        tallies = Inquiry.where(created_at: first_month..@now.end_of_month)
                         .group(Arel.sql("date_trunc('month', created_at)"))
                         .count
                         .transform_keys { |time| time.to_date.beginning_of_month }

        CHART_MONTHS.times.map do |offset|
          month = (first_month + offset.months).to_date
          [ I18n.l(month, format: "%b"), tallies.fetch(month, 0) ]
        end
      end
    end

    # ── Activity ─────────────────────────────────────────────────────────────

    def audit? = policy(AuditLog).index?

    def recent_activity
      @recent_activity ||= return_empty_unless(audit?) do
        AuditLog.includes(:user).order(created_at: :desc).limit(LIST_SIZE).to_a
      end
    end

    private

    attr_reader :user

    # Archived stock is out of the business's sight, so it is out of the
    # dashboard's numbers too.
    def base_vehicles = Vehicle.kept

    def policy(record) = Pundit.policy!(user, record)

    def return_empty_unless(condition)
      condition ? yield : []
    end
  end
end
