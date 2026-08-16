# frozen_string_literal: true

module UI
  # Menu anchored to a trigger. Closing on outside click, Escape and item
  # activation is handled by the `dropdown` Stimulus controller.
  class DropdownComponent < ApplicationComponent
    renders_one :trigger
    renders_many :items, "ItemComponent"

    def initialize(align: :right, label: nil, icon: :dots, **options)
      @align   = align
      @label   = label
      @icon    = icon
      @options = options
    end

    private

    attr_reader :label, :icon

    def menu_alignment = @align == :left ? "left-0" : "right-0"

    def wrapper_classes = class_names("relative inline-block", @options[:class])

    # A single row in the menu: a link, a button, or a divider.
    class ItemComponent < ApplicationComponent
      def initialize(label: nil, href: nil, icon: nil, method: nil, confirm: nil,
                     tone: :default, divider: false, **options)
        @label   = label
        @href    = href
        @icon    = icon
        @method  = method
        @confirm = confirm
        @tone    = tone
        @divider = divider
        @options = options
      end

      def call
        return tag.div("", class: "my-1 border-t border-line") if @divider

        @href ? link_to(@href, **item_options) { body } : tag.button(type: "button", **item_options) { body }
      end

      private

      def body
        safe_join([
          (render(UI::IconComponent.new(@icon, class: "size-4 shrink-0 opacity-70")) if @icon),
          tag.span(@label.presence || content)
        ].compact)
      end

      def item_options
        data = @options.delete(:data) || {}
        data = data.merge(turbo_method: @method) if @method
        data = data.merge(turbo_confirm: @confirm) if @confirm
        data = data.merge(action: [ data[:action], "dropdown#close" ].compact.join(" "))

        @options.merge(class: classes, data: data, role: "menuitem")
      end

      def classes
        tone = @tone == :danger ? "text-danger hover:bg-danger-soft" : "text-ink hover:bg-surface-3"

        class_names(
          "w-full flex items-center gap-2.5 px-3 py-2 text-sm text-left transition-colors",
          tone, @options[:class]
        )
      end
    end
  end
end
