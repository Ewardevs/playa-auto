class CreateBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.string  :name,   null: false
      t.string  :slug,   null: false
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      # Prepared for the future public site (see SEO concern)
      t.string :meta_title
      t.text   :meta_description

      t.integer :vehicles_count, null: false, default: 0

      t.timestamps
    end

    add_index :brands, :name, unique: true
    add_index :brands, :slug, unique: true
    add_index :brands, :active
  end
end
