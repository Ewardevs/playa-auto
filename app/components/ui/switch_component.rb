# frozen_string_literal: true

module UI
  # Boolean control rendered as a switch. Backed by a real checkbox so it
  # submits, validates and keyboard-navigates like any other form input.
  class SwitchComponent < ApplicationComponent
    def initialize(form:, attribute:, label: nil, hint: nil, **options)
      @form      = form
      @attribute = attribute
      @label     = label
      @hint      = hint
      @options   = options
    end

    private

    attr_reader :form, :attribute, :hint

    def label_text
      @label || form.object.class.try(:human_attribute_name, attribute) || attribute.to_s.humanize
    end
  end
end
