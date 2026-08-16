# Everything the public site needs from the domain that the admin panel alone
# did not require.
class AddPublicSiteSupport < ActiveRecord::Migration[8.1]
  def change
    change_table :settings, bulk: true do |t|
      # Whether sold stock stays visible in the public catalogue. The business
      # decides; it is never a URL parameter.
      t.boolean :show_sold_vehicles, null: false, default: false

      # Analytics is configured, not hardcoded in a view.
      t.string :google_analytics_id
      t.string :google_tag_manager_id
      t.string :meta_pixel_id
    end

    # Counterpart to views_count, so the admin dashboard can report on the
    # channel that actually converts.
    add_column :vehicles, :whatsapp_clicks_count, :integer, null: false, default: 0

    # The "por qué comprarnos" strip on the public site. A table rather than
    # hardcoded copy, so the playa can change its own selling points.
    create_table :differentials do |t|
      t.string  :title,       null: false
      t.string  :description
      t.string  :icon,        null: false, default: "check_circle"
      t.integer :position,    null: false, default: 0
      t.boolean :active,      null: false, default: true

      t.timestamps
    end

    add_index :differentials, [ :active, :position ]
  end
end
