# Singleton row holding the editable copy of the future public site
# (home hero + about section). FAQs live in their own table because they are a
# collection with their own CRUD.
class CreateSiteContents < ActiveRecord::Migration[8.1]
  def change
    create_table :site_contents do |t|
      ## Home — main banner
      t.string :hero_title
      t.string :hero_subtitle
      t.text   :hero_text
      t.string :hero_button_label
      t.string :hero_button_url

      ## About us
      t.string :about_title
      t.text   :about_description

      t.timestamps
    end
  end
end
