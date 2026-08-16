# frozen_string_literal: true

module UI
  # One form control: label, input, hint and inline error, styled identically
  # everywhere. Errors come from the model, so what the user sees is exactly
  # what the backend validated.
  #
  #   render UI::FieldComponent.new(form: f, attribute: :price, type: :number, prefix: "$")
  class FieldComponent < ApplicationComponent
    INPUT_BASE = <<~CLASSES.squish
      w-full rounded-md border bg-surface text-ink text-sm
      placeholder:text-faint transition-colors
      disabled:opacity-55 disabled:bg-surface-2
    CLASSES

    def initialize(form:, attribute:, type: :text, label: nil, hint: nil,
                   choices: nil, include_blank: nil, prefix: nil, suffix: nil,
                   rows: 4, required: false, wrapper_class: nil, **input_options)
      @form           = form
      @attribute      = attribute
      @type           = type.to_sym
      @label          = label
      @hint           = hint
      @choices        = choices
      @include_blank  = include_blank
      @prefix         = prefix
      @suffix         = suffix
      @rows           = rows
      @required       = required
      @wrapper_class  = wrapper_class
      @input_options  = input_options
    end

    private

    attr_reader :form, :attribute, :type, :hint, :prefix, :suffix

    def object = form.object

    def errors
      return [] unless object.respond_to?(:errors)

      object.errors[attribute]
    end

    def invalid? = errors.any?

    def label_text
      @label || object.class.try(:human_attribute_name, attribute) || attribute.to_s.humanize
    end

    def required? = @required

    def field_id = form.field_id(attribute)

    def describedby
      ids = []
      ids << "#{field_id}_error" if invalid?
      ids << "#{field_id}_hint"  if hint.present?
      ids.presence&.join(" ")
    end

    def input_classes
      border = invalid? ? "border-danger focus:border-danger" : "border-line focus:border-line-strong"
      pad    = if prefix.present?
                 "pl-7 pr-3"
      elsif suffix.present?
                 "pl-3 pr-10"
      else
                 "px-3"
      end

      class_names(INPUT_BASE, border, pad, ("h-9.5" unless multiline?), ("py-2" if multiline?))
    end

    def multiline? = type == :textarea

    def options
      @input_options.merge(
        class: class_names(input_classes, @input_options[:class]),
        required: required?,
        "aria-invalid": invalid?.presence,
        "aria-describedby": describedby
      ).compact
    end

    def control
      case type
      when :textarea then form.text_area(attribute, rows: @rows, **options)
      when :select   then form.select(attribute, @choices, { include_blank: @include_blank }, **options)
      when :number   then form.number_field(attribute, **options)
      when :email    then form.email_field(attribute, **options)
      when :password then form.password_field(attribute, **options)
      when :tel      then form.telephone_field(attribute, **options)
      when :url      then form.url_field(attribute, **options)
      when :date     then form.date_field(attribute, **options)
      when :datetime then form.datetime_local_field(attribute, **options)
      when :file     then file_control
      else form.text_field(attribute, **options)
      end
    end

    def file_control
      form.file_field(attribute, **@input_options.merge(
        class: class_names(
          "w-full text-sm text-muted cursor-pointer",
          "file:mr-3 file:py-2 file:px-3.5 file:rounded-md file:border-0",
          "file:text-sm file:font-medium file:bg-surface-3 file:text-ink",
          "hover:file:bg-line file:cursor-pointer file:transition-colors",
          @input_options[:class]
        )
      ))
    end
  end
end
