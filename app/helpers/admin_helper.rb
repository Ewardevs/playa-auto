# Formatting helpers shared across the admin panel.
#
# Money and dates read their format from the company Setting rather than from
# constants, so changing the currency in Configuración changes every screen.
module AdminHelper
  # 32000.0 => "$ 32.000"
  def money(amount, symbol: true, precision: 0)
    return "—" if amount.blank?

    formatted = number_with_precision(
      amount,
      precision: precision,
      delimiter: ".",
      separator: ",",
      strip_insignificant_zeros: true
    )

    symbol ? "#{Setting.current.currency_symbol} #{formatted}" : formatted
  end

  # 15000 => "15.000 km"
  def mileage(kilometres)
    return "—" if kilometres.blank?

    "#{number_with_delimiter(kilometres, delimiter: '.')} km"
  end

  def short_date(value)
    return "—" if value.blank?

    l(value.to_date, format: :short)
  end

  def long_datetime(value)
    return "—" if value.blank?

    l(value.in_time_zone, format: :long)
  end

  # "hace 3 días" — with the exact timestamp on hover.
  def time_ago(value)
    return "—" if value.blank?

    tag.span(t("admin.time.ago", time: time_ago_in_words(value)), title: long_datetime(value))
  end

  def blank_dash(value)
    value.presence || tag.span("—", class: "text-faint")
  end

  # Renders a phone number as a click-to-call link.
  def phone_link(number, **options)
    return blank_dash(nil) if number.blank?

    link_to number, "tel:#{number.gsub(/[^\d+]/, '')}", **options
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
