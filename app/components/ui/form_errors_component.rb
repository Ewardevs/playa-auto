# frozen_string_literal: true

module UI
  # Summary shown at the top of a form when the backend rejected the submission.
  # It states what went wrong and how many fields need attention; the fields
  # themselves carry the specific messages.
  class FormErrorsComponent < ApplicationComponent
    def initialize(record)
      @record = record
    end

    def render? = @record.respond_to?(:errors) && @record.errors.any?

    private

    attr_reader :record

    def count = record.errors.count

    def messages = record.errors.full_messages
  end
end
