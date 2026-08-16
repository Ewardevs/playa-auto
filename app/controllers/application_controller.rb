class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :expose_current_user

  # Devise screens get the split brand layout; everything else falls back to the
  # application layout (the admin panel overrides this with its own).
  layout :layout_for_request

  private

  def layout_for_request
    devise_controller? ? "auth" : "application"
  end

  # Makes the acting user available to models and services (the audit trail
  # reads it) without threading it through every call.
  def expose_current_user
    Current.user = current_user
  end
end
