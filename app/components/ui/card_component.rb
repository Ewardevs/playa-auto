# frozen_string_literal: true

module UI
  # Panel surface used for every block of content. `flush: true` removes body
  # padding so tables can sit edge to edge inside a card.
  class CardComponent < ApplicationComponent
    renders_one :actions
    renders_one :footer

    def initialize(title: nil, subtitle: nil, icon: nil, flush: false, **options)
      @title    = title
      @subtitle = subtitle
      @icon     = icon
      @flush    = flush
      @options  = options
    end

    private

    attr_reader :title, :subtitle, :icon

    def header? = title.present? || actions?

    def wrapper_classes
      class_names(
        "bg-surface border border-line rounded-panel overflow-hidden",
        @options[:class]
      )
    end

    def body_classes = @flush ? "" : "p-5"
  end
end
