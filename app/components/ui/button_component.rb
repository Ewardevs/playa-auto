# frozen_string_literal: true

module UI
  # The one place a button is styled. Renders a <button>, or an <a> when given
  # an href, so links that look like buttons stay real links.
  class ButtonComponent < ApplicationComponent
    VARIANTS = {
      # Primary actions are solid graphite — the configurator look.
      primary: "bg-ink text-canvas hover:bg-ink/90 border-ink",
      secondary: "bg-surface text-ink border-line hover:bg-surface-2 hover:border-line-strong",
      accent: "bg-accent text-accent-ink border-accent hover:brightness-105",
      danger: "bg-danger text-white border-danger hover:brightness-110",
      ghost: "bg-transparent text-muted border-transparent hover:bg-surface-3 hover:text-ink",
      quiet: "bg-surface-3 text-ink border-transparent hover:bg-line"
    }.freeze

    SIZES = {
      sm: "h-8 px-3 text-[0.8125rem] gap-1.5",
      md: "h-9.5 px-4 text-sm gap-2",
      lg: "h-11 px-5 text-[0.9375rem] gap-2"
    }.freeze

    def initialize(label: nil, href: nil, variant: :secondary, size: :md,
                   icon: nil, method: nil, confirm: nil, disabled: false,
                   type: "button", full: false, **options)
      @label    = label
      @href     = href
      @variant  = VARIANTS.key?(variant) ? variant : :secondary
      @size     = SIZES.key?(size) ? size : :md
      @icon     = icon
      @method   = method
      @confirm  = confirm
      @disabled = disabled
      @type     = type
      @full     = full
      @options  = options
    end

    def call
      if @href
        link_to(@href, **html_options) { body }
      else
        tag.button(type: @type, disabled: @disabled, **html_options) { body }
      end
    end

    private

    def body
      safe_join([ icon_markup, label_markup ].compact)
    end

    def icon_markup
      return if @icon.blank?

      render UI::IconComponent.new(@icon, class: "size-4 shrink-0")
    end

    def label_markup
      text = @label.presence || content
      return if text.blank?

      tag.span(text, class: "truncate")
    end

    def html_options
      data = @options.delete(:data) || {}
      data = data.merge(turbo_method: @method) if @method
      data = data.merge(turbo_confirm: @confirm) if @confirm

      @options.merge(
        class: class_names(base_classes, @options[:class]),
        data: data
      )
    end

    def base_classes
      [
        "inline-flex items-center justify-center whitespace-nowrap rounded-md border",
        "font-medium transition-colors duration-150",
        "disabled:opacity-45 disabled:pointer-events-none",
        SIZES[@size],
        VARIANTS[@variant],
        ("w-full" if @full)
      ]
    end
  end
end
