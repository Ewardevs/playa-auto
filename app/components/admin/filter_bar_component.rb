# frozen_string_literal: true

module Admin
  # Search + filter form for list screens. Selects submit on change; the text
  # field submits on Enter. Everything is a plain GET form, so filters are
  # shareable URLs and the back button behaves.
  class FilterBarComponent < ApplicationComponent
    Chip = Struct.new(:label, :value, :count, keyword_init: true)

    renders_many :filters
    renders_one :extra

    def initialize(url:, query: nil, query_param: :q, placeholder: nil,
                   chips: [], chip_param: nil, active_chip: nil)
      @url         = url
      @query       = query
      @query_param = query_param
      @placeholder = placeholder
      @chips       = Array(chips)
      @chip_param  = chip_param
      @active_chip = active_chip.presence
    end

    private

    attr_reader :url, :query, :query_param, :placeholder, :chips, :chip_param

    def chips? = chips.any? && chip_param.present?

    def chip_active?(chip) = @active_chip.to_s == chip.value.to_s

    def chip_url(chip)
      helpers.url_for(
        request.query_parameters.merge(chip_param => chip.value.presence, page: nil).compact.symbolize_keys
      )
    end

    def chip_classes(chip)
      base = "inline-flex items-center gap-1.5 h-8 px-3 rounded-md text-[0.8125rem] font-medium border transition-colors"

      if chip_active?(chip)
        "#{base} bg-ink text-canvas border-ink"
      else
        "#{base} bg-surface text-muted border-line hover:text-ink hover:border-line-strong"
      end
    end

    # Any filter beyond the current chip means the user has narrowed the list.
    def filtered?
      (request.query_parameters.keys - [ chip_param.to_s, "page", "sort", "dir" ]).any? do |key|
        request.query_parameters[key].present?
      end
    end

    def reset_url = url
  end
end
