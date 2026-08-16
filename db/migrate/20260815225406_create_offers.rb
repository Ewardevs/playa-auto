class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :vehicle, null: false, foreign_key: true, index: { unique: true }

      t.decimal :previous_price,  precision: 12, scale: 2, null: false
      t.decimal :promo_price,     precision: 12, scale: 2, null: false
      t.date    :starts_on, null: false
      t.date    :ends_on,   null: false
      t.boolean :active,    null: false, default: true

      t.timestamps
    end

    add_index :offers, :active
    add_index :offers, [ :starts_on, :ends_on ]
  end
end
