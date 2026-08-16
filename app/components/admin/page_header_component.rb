# frozen_string_literal: true

module Admin
  # Title block at the top of every screen: what this page is, and the primary
  # actions available on it.
  class PageHeaderComponent < ApplicationComponent
    renders_one :actions
    renders_one :meta

    def initialize(title:, description: nil, back_to: nil, back_label: nil)
      @title       = title
      @description = description
      @back_to     = back_to
      @back_label  = back_label
    end

    private

    attr_reader :title, :description, :back_to, :back_label
  end
end
