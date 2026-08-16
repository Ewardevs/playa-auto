# frozen_string_literal: true

module Admin
  # Thin top rail: the sidebar toggles, the breadcrumb trail, a global vehicle
  # search and the theme switch. Deliberately slim — the content is the point.
  class HeaderComponent < ApplicationComponent
    def initialize(crumbs: [], search_path: nil, search_query: nil)
      @crumbs       = crumbs
      @search_path  = search_path
      @search_query = search_query
    end

    private

    attr_reader :crumbs, :search_path, :search_query

    def searchable? = search_path.present?
  end
end
