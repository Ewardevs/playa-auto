class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    # Internal vehicle codes are drawn from a sequence so concurrent creations
    # can never collide on the unique index.
    reversible do |dir|
      dir.up   { execute "CREATE SEQUENCE IF NOT EXISTS vehicle_codes START 1" }
      dir.down { execute "DROP SEQUENCE IF EXISTS vehicle_codes" }
    end

    create_table :vehicles do |t|
      t.references :brand,         null: false, foreign_key: true
      t.references :vehicle_model, null: false, foreign_key: true
      t.references :category,      null: false, foreign_key: true
      # Who published it. Nullified rather than cascaded so removing a seller
      # never destroys inventory.
      t.references :user,          null: true,  foreign_key: { on_delete: :nullify }

      ## Identification
      t.string :code, null: false
      t.string :slug, null: false

      ## Basic information
      t.integer :year, null: false

      ## Commercial information
      t.decimal :price,          precision: 12, scale: 2, null: false
      t.decimal :previous_price, precision: 12, scale: 2

      ## Specifications
      t.integer :mileage, null: false, default: 0
      t.integer :fuel_type,    null: false, default: 0
      t.integer :transmission, null: false, default: 0
      t.string  :engine
      t.string  :color

      ## Content
      t.text :description
      t.text :equipment

      ## State
      t.integer  :status,   null: false, default: 0
      t.boolean  :featured, null: false, default: false
      t.boolean  :on_offer, null: false, default: false
      t.datetime :published_at

      ## Metrics — denormalised so the dashboard never has to aggregate live
      t.integer :views_count,     null: false, default: 0
      t.integer :inquiries_count, null: false, default: 0

      ## SEO, prepared for the future public site
      t.string :meta_title
      t.text   :meta_description
      t.text   :seo_description

      ## Soft delete / archiving
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :vehicles, :code, unique: true
    add_index :vehicles, :slug, unique: true
    add_index :vehicles, :status
    add_index :vehicles, :featured
    add_index :vehicles, :on_offer
    add_index :vehicles, :year
    add_index :vehicles, :price
    add_index :vehicles, :published_at
    add_index :vehicles, :discarded_at

    # The admin list and the future public catalogue both filter on
    # "not archived + a given status", ordered by recency.
    add_index :vehicles, [ :discarded_at, :status, :published_at ],
              name: "index_vehicles_on_discarded_status_published"

    # Dashboard "most viewed" / "most inquired" leaderboards.
    add_index :vehicles, :views_count,     order: { views_count: :desc }
    add_index :vehicles, :inquiries_count, order: { inquiries_count: :desc }
  end
end
