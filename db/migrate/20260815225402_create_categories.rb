class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false
      t.text    :description
      t.boolean :active,      null: false, default: true
      t.integer :position,    null: false, default: 0

      t.string :meta_title
      t.text   :meta_description

      t.integer :vehicles_count, null: false, default: 0

      t.timestamps
    end

    add_index :categories, :name, unique: true
    add_index :categories, :slug, unique: true
    add_index :categories, :active
  end
end
