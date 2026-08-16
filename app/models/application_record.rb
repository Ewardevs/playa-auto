class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Translated label for an enum value, e.g.
  #   Vehicle.human_enum_name(:status, :available) # => "Disponible"
  # Looked up under activerecord.attributes.<model>.<enum_plural>.<value>.
  def self.human_enum_name(enum_name, value)
    return "" if value.blank?

    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{value}",
      default: value.to_s.humanize
    )
  end
end
