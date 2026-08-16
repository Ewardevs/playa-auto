class CreateVehicleModels < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_models do |t|
      t.references :brand, null: false, foreign_key: true
      t.string  :name,   null: false
      t.string  :slug,   null: false
      t.boolean :active, null: false, default: true

      t.integer :vehicles_count, null: false, default: 0

      t.timestamps
    end

    # A model name only has to be unique within its brand (Ford Focus vs. VW Focus)
    add_index :vehicle_models, [ :brand_id, :name ], unique: true
    add_index :vehicle_models, [ :brand_id, :slug ], unique: true
    add_index :vehicle_models, :active
  end
end
