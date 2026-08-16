module SEO
  # Carries a page's SEO for the layout to render: title, description,
  # canonical and Open Graph.
  #
  # A plain object rather than a pile of instance variables, so every page sets
  # the same fields and the layout has exactly one thing to read.
  class Metadata
    MAX_DESCRIPTION = 160

    attr_accessor :canonical, :og_type, :robots
    attr_writer :title, :description, :image_url

    def initialize(setting:, url: nil)
      @setting   = setting
      @canonical = url
      @og_type   = "website"
      @robots    = "index, follow"
    end

    # "Toyota Hilux 2024 | Playa Guaraní" — the company name is appended once,
    # and never duplicated when the page title already is the company name.
    def title
      return suffix if @title.blank? || @title == suffix

      "#{@title} | #{suffix}"
    end

    def raw_title = @title.presence || suffix

    def description
      @description.to_s.squish.truncate(MAX_DESCRIPTION, separator: " ").presence
    end

    def image_url = @image_url

    def site_name = suffix

    def noindex!
      @robots = "noindex, follow"
    end

    private

    def suffix = @setting.company_name
  end
end
