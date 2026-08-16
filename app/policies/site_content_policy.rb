# frozen_string_literal: true

# Site copy is the Editor role's domain, shared with the administrators.
class SiteContentPolicy < ApplicationPolicy
  def show?   = user.manages_content?
  def update? = user.manages_content?

  def permitted_attributes
    %i[
      hero_title hero_subtitle hero_text hero_button_label hero_button_url
      hero_image about_title about_description about_image
    ]
  end
end
