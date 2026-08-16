# Formatting shared by the admin panel and the public site.
#
# Money reads its symbol from the company Setting, so changing the currency in
# Configuración changes every screen and every page at once.
module FormattingHelper
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

  def blank_dash(value)
    value.presence || tag.span("—", class: "opacity-50")
  end

  # Click-to-call link, with the number stripped down to something dialable.
  def phone_link(number, **options)
    return blank_dash(nil) if number.blank?

    link_to number, "tel:#{number.gsub(/[^\d+]/, '')}", **options
  end
end
