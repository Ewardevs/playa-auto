# frozen_string_literal: true

module Admin
  # The admin table. Columns are declared at the call site and rendered once per
  # row, which keeps every list screen consistent without a partial per module:
  #
  #   render Admin::DataTableComponent.new(rows: @vehicles) do |table|
  #     table.column(label: "Código", sort: :code) { |v| v.code }
  #     table.column(label: "Precio", align: :right) { |v| money(v.price) }
  #   end
  #
  # Columns are collected through a plain builder rather than a ViewComponent
  # slot: a slot renders whatever it is given, but a column needs to stay a
  # callable that runs once per row.
  #
  # Sortable headers rewrite the current query string, so sorting composes with
  # whatever filters are already applied.
  class DataTableComponent < ApplicationComponent
    Column = Struct.new(:label, :align, :width, :sort, :cell, :cell_class, keyword_init: true)

    renders_one :empty_state
    renders_one :toolbar
    renders_one :footer

    def initialize(rows:, sort_param: :sort, direction_param: :dir)
      @rows            = rows
      @columns         = []
      @sort_param      = sort_param
      @direction_param = direction_param
    end

    # Called from the view's block. Returns nil so nothing leaks into the buffer.
    def column(label: nil, align: :left, width: nil, sort: nil, cell_class: nil, &block)
      @columns << Column.new(
        label: label, align: align, width: width, sort: sort, cell_class: cell_class, cell: block
      )
      nil
    end

    # Force the caller's block to run so the columns are registered before the
    # template asks for them.
    def before_render
      content
    end

    private

    attr_reader :rows, :columns

    def any? = rows.any?

    def alignment(column)
      case column.align
      when :right  then "text-right"
      when :center then "text-center"
      else "text-left"
      end
    end

    def current_sort = params[@sort_param].presence

    def current_direction = params[@direction_param] == "desc" ? "desc" : "asc"

    def sorted_by?(column) = column.sort.present? && current_sort == column.sort.to_s

    # Clicking the active column flips the direction; a new column starts ascending.
    def sort_url(column)
      direction = sorted_by?(column) && current_direction == "asc" ? "desc" : "asc"

      helpers.url_for(
        request.query_parameters.merge(
          @sort_param => column.sort, @direction_param => direction, page: nil
        ).compact.symbolize_keys
      )
    end

    def sort_icon(column)
      return :chevron_down unless sorted_by?(column)

      current_direction == "asc" ? :chevron_up : :chevron_down
    end
  end
end
