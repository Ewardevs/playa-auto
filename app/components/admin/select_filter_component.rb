# frozen_string_literal: true

module Admin
  # A single dropdown inside the filter bar. Submits its form on change so a
  # filter takes effect without hunting for a button.
  class SelectFilterComponent < ApplicationComponent
    def initialize(name:, choices:, selected: nil, prompt:)
      @name     = name
      @choices  = choices
      @selected = selected
      @prompt   = prompt
    end

    def call
      select_tag(
        @name,
        options_for_select(@choices, @selected.to_s),
        include_blank: @prompt,
        data: { action: "change->filter-form#submit" },
        class: "h-9 pl-3 pr-8 rounded-md border border-line bg-surface text-sm text-ink " \
               "focus:border-line-strong transition-colors max-w-44"
      )
    end
  end
end
