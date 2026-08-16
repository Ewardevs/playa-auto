# Singleton row holding every piece of company information that must never be
# hardcoded in views, components or controllers. Consumed by Admin today and by
# the future public Site.
class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      ## Identity
      t.string :company_name, null: false, default: "Playa de Autos"
      t.string :tagline

      ## Contact
      t.string :phone
      t.string :whatsapp
      t.string :email
      t.string :address
      t.text   :opening_hours

      ## Links
      t.string :google_maps_url
      t.string :instagram_url
      t.string :facebook_url
      t.string :tiktok_url

      ## General
      t.string :currency,      null: false, default: "USD"
      t.string :currency_symbol, null: false, default: "$"
      t.string :locale,        null: false, default: "es"

      t.timestamps
    end
  end
end
