# frozen_string_literal: true

module Admin
  # Trail of ancestors for the current screen. Built from an array of
  # [label, path] pairs set by the controller via `breadcrumb`.
  class BreadcrumbsComponent < ApplicationComponent
    def initialize(crumbs:)
      @crumbs = Array(crumbs)
    end

    def render? = @crumbs.any?

    private

    attr_reader :crumbs
  end
end
