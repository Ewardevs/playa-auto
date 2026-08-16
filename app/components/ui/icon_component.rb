# frozen_string_literal: true

module UI
  # Inline SVG icons. Kept as path data in one file so the panel has no icon
  # font, no sprite request and nothing for importmap to pin — an unknown name
  # renders nothing rather than breaking the page.
  class IconComponent < ApplicationComponent
    PATHS = {
      # Navigation
      gauge: "M12 14l4-4M3.34 19a10 10 0 1 1 17.32 0",
      car: "M19 17h2v-5l-2.5-5.5A2 2 0 0 0 16.7 5H7.3a2 2 0 0 0-1.8 1.5L3 12v5h2m14 0a2 2 0 1 1-4 0m4 0a2 2 0 1 0-4 0m-6 0a2 2 0 1 1-4 0m4 0a2 2 0 1 0-4 0m-2-5h16",
      tag: "M12.6 2.7l8.7 8.7a1 1 0 0 1 0 1.4l-7.5 7.5a1 1 0 0 1-1.4 0l-8.7-8.7A1 1 0 0 1 3.4 11V4a1 1 0 0 1 1-1h7a1 1 0 0 1 .7.3zM7.5 7.5h.01",
      layers: "M12 2l9 5-9 5-9-5 9-5zM3 12l9 5 9-5M3 17l9 5 9-5",
      grid: "M3 3h7v7H3zM14 3h7v7h-7zM14 14h7v7h-7zM3 14h7v7H3z",
      percent: "M19 5L5 19M6.5 6.5a2 2 0 1 0 0 .01M17.5 17.5a2 2 0 1 0 0 .01",
      inbox: "M22 12h-6l-2 3h-4l-2-3H2M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z",
      file_text: "M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6M16 13H8M16 17H8M10 9H8",
      settings: "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z|M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
      users: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75",
      logout: "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9",
      history: "M3 3v5h5M3.05 13A9 9 0 1 0 6 5.3L3 8M12 7v5l4 2",

      # Actions
      plus: "M12 5v14M5 12h14",
      pencil: "M17 3a2.85 2.85 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5z",
      trash: "M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2m3 0v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M10 11v6M14 11v6",
      eye: "M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z|M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
      copy: "M20 9h-9a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h9a2 2 0 0 0 2-2v-9a2 2 0 0 0-2-2zM5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1",
      search: "M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16zM21 21l-4.3-4.3",
      filter: "M22 3H2l8 9.46V19l4 2v-8.54z",
      archive: "M21 8v13H3V8M1 3h22v5H1zM10 12h4",
      restore: "M3 3v5h5M3.05 13A9 9 0 1 0 6 5.3L3 8",
      upload: "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12",
      image: "M19 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2zM8.5 10a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM21 15l-5-5L5 21",
      grip: "M9 5h.01M9 12h.01M9 19h.01M15 5h.01M15 12h.01M15 19h.01",
      star: "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z",
      key: "M2.6 18.6a2 2 0 0 0 2.8 2.8M15 7a4 4 0 1 0 0-.01M21 2l-9.6 9.6M15.5 7.5l3 3M7 13l-4.4 4.4a2 2 0 0 0 0 2.8 2 2 0 0 0 2.8 0L9.8 15.8",
      power: "M12 2v10M18.4 6.6a9 9 0 1 1-12.8 0",

      # Chrome
      chevron_down: "M6 9l6 6 6-6",
      chevron_up: "M18 15l-6-6-6 6",
      chevron_left: "M15 18l-6-6 6-6",
      chevron_right: "M9 18l6-6-6-6",
      chevrons_left: "M11 17l-5-5 5-5M18 17l-5-5 5-5",
      chevrons_right: "M13 17l5-5-5-5M6 17l5-5-5-5",
      x: "M18 6L6 18M6 6l12 12",
      check: "M20 6L9 17l-5-5",
      menu: "M3 12h18M3 6h18M3 18h18",
      dots: "M12 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2zM12 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2zM12 20a1 1 0 1 0 0-2 1 1 0 0 0 0 2z",
      sun: "M12 17a5 5 0 1 0 0-10 5 5 0 0 0 0 10zM12 1v2M12 21v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M1 12h2M21 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4",
      moon: "M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z",
      alert: "M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0zM12 9v4M12 17h.01",
      info: "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20zM12 16v-4M12 8h.01",
      check_circle: "M22 11.1V12a10 10 0 1 1-5.9-9.1M22 4L12 14.01l-3-3",
      phone: "M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2 4.2 2 2 0 0 1 4 2h3a2 2 0 0 1 2 1.7c.1 1 .4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8.1 9.9a16 16 0 0 0 6 6l1.3-1.1a2 2 0 0 1 2.1-.5c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2z",
      mail: "M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2zM22 7l-10 6L2 7",
      calendar: "M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z",
      external: "M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6M15 3h6v6M10 14L21 3",
      gauge_circle: "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20zM12 14l4-4",
      trending: "M22 7l-8.5 8.5-5-5L2 17M16 7h6v6"
    }.freeze

    def initialize(name, **options)
      @name    = name.to_s.tr("-", "_").to_sym
      @options = options
    end

    def call
      paths = PATHS[@name]
      return "".html_safe if paths.blank?

      tag.svg(
        safe_join(paths.split("|").map { |d| tag.path(d: d) }),
        xmlns: "http://www.w3.org/2000/svg",
        viewBox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        "stroke-width": @options.delete(:stroke_width) || 1.75,
        "stroke-linecap": "round",
        "stroke-linejoin": "round",
        "aria-hidden": true,
        **@options,
        class: class_names("shrink-0", @options[:class])
      )
    end
  end
end
