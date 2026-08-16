# Images are modelled explicitly instead of a bare `has_many_attached` so that
# ordering and the "main image" flag are first-class, queryable columns.
class CreateVehicleImages < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_images do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      # Named `main` rather than `primary` to stay clear of the SQL reserved word.
      t.boolean :main,     null: false, default: false
      t.string  :alt_text

      t.timestamps
    end

    add_index :vehicle_images, [ :vehicle_id, :position ]

    # At most one main image per vehicle, enforced by the database rather than
    # by application code alone.
    add_index :vehicle_images, [ :vehicle_id, :main ],
              unique: true,
              where: "main = true",
              name: "index_vehicle_images_one_main_per_vehicle"
  end
end
