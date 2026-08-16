# Base for every ViewComponent in the app.
#
# Components stay presentational: they receive already-loaded records and
# decide how things look. Business rules belong in models, services and
# policies, never here.
class ApplicationComponent < ViewComponent::Base
  # `current_setting` is available on both sides; `site_content` only on the
  # public site, and only its components ask for it.
  delegate :current_user, :policy, :current_setting, :site_content, to: :helpers

  # Formatting is shared with the views, so components read prices, mileages and
  # dates through the same helpers rather than reimplementing them.
  delegate :money, :mileage, :short_date, :long_datetime, :blank_dash, :phone_link, to: :helpers

  private

  # Merges a component's own classes with any passed in by the caller, so every
  # component can be adjusted at the call site without string juggling.
  def class_names(*sets)
    sets.flatten.compact_blank.join(" ")
  end
end
