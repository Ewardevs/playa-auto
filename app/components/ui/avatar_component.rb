# frozen_string_literal: true

module UI
  # User avatar, falling back to initials when no photo has been uploaded.
  class AvatarComponent < ApplicationComponent
    SIZES = {
      xs: { box: "size-6",  text: "text-[0.625rem]" },
      sm: { box: "size-8",  text: "text-xs" },
      md: { box: "size-10", text: "text-sm" },
      lg: { box: "size-16", text: "text-lg" }
    }.freeze

    def initialize(user, size: :sm, **options)
      @user    = user
      @size    = SIZES.key?(size) ? size : :sm
      @options = options
    end

    def call
      tag.span(class: classes, title: @user&.display_name) do
        photo? ? image : tag.span(@user&.initials)
      end
    end

    private

    def photo? = @user.respond_to?(:avatar) && @user.avatar.attached?

    def image
      image_tag(@user.avatar.variant(:thumb), class: "size-full object-cover", alt: @user.display_name, loading: "lazy")
    end

    def classes
      class_names(
        "inline-grid place-items-center shrink-0 overflow-hidden rounded-full",
        "bg-surface-3 text-muted font-semibold uppercase select-none",
        SIZES[@size][:box], SIZES[@size][:text], @options[:class]
      )
    end
  end
end
