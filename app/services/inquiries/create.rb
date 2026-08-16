module Inquiries
  # Creates an enquiry sent from the public site.
  #
  # The record is the same `Inquiry` the sales team works in the admin panel —
  # there is no parallel model and nothing to sync. Spam defences live here
  # rather than in the controller so they apply to every entry point:
  #
  #   - a honeypot field no human ever fills in
  #   - a minimum time-on-form, since bots submit instantly
  #   - de-duplication, so a double-tap on a slow connection files one enquiry
  class Create
    MIN_FILL_SECONDS = 3
    DUPLICATE_WINDOW = 10.minutes

    Result = Struct.new(:inquiry, :status, keyword_init: true) do
      def success? = status == :created
      # Silently accepted but discarded: a bot must not learn it was caught.
      def spam?      = status == :spam
      def duplicate? = status == :duplicate
      def ok?        = success? || spam? || duplicate?
    end

    def initialize(attributes:, vehicle: nil, honeypot: nil, started_at: nil)
      @attributes = attributes
      @vehicle    = vehicle
      @honeypot   = honeypot
      @started_at = started_at
    end

    def call
      return Result.new(inquiry: build, status: :spam) if spam?

      existing = duplicate_of
      return Result.new(inquiry: existing, status: :duplicate) if existing

      inquiry = build
      inquiry.save ? Result.new(inquiry: inquiry, status: :created)
                   : Result.new(inquiry: inquiry, status: :invalid)
    end

    private

    def build
      Inquiry.new(@attributes).tap do |inquiry|
        inquiry.vehicle = @vehicle
        inquiry.status  = :new_lead
      end
    end

    def spam?
      @honeypot.present? || submitted_too_fast?
    end

    def submitted_too_fast?
      return false if @started_at.blank?

      opened_at = Time.zone.at(@started_at.to_i)
      return false if opened_at.year < 2000 # unparseable: don't punish the visitor

      (Time.current - opened_at) < MIN_FILL_SECONDS
    rescue RangeError, TypeError
      false
    end

    # Same phone, same vehicle, moments apart — one person tapping twice.
    def duplicate_of
      phone = @attributes[:phone].presence
      return if phone.blank?

      Inquiry.where(phone: phone, vehicle_id: @vehicle&.id)
             .where(created_at: DUPLICATE_WINDOW.ago..)
             .order(:created_at)
             .last
    end
  end
end
