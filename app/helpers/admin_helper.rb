# Admin-only formatting. Anything the public site also needs lives in
# FormattingHelper.
module AdminHelper
  # "hace 3 días" — with the exact timestamp on hover.
  def time_ago(value)
    return "—" if value.blank?

    tag.span(t("admin.time.ago", time: time_ago_in_words(value)), title: long_datetime(value))
  end

  def whatsapp_link(number, message: nil, **options)
    return if number.blank?

    url = "https://wa.me/#{number.gsub(/\D/, '')}"
    url += "?text=#{CGI.escape(message)}" if message.present?

    link_to url, target: "_blank", rel: "noopener", **options do
      yield if block_given?
    end
  end
end
