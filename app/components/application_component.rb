# Base for every ViewComponent in the app.
#
# Components stay presentational: they receive already-loaded records and
# decide how things look. Business rules belong in models, services and
# policies, never here.
class ApplicationComponent < ViewComponent::Base
  delegate :current_user, :policy, :current_setting, to: :helpers

  private

  # Merges a component's own classes with any passed in by the caller, so every
  # component can be adjusted at the call site without string juggling.
  def class_names(*sets)
    sets.flatten.compact_blank.join(" ")
  end
end
