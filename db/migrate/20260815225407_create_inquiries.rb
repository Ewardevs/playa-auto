class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      # Optional: the future public site will also expose a general contact form
      # that is not tied to a particular vehicle.
      t.references :vehicle, null: true, foreign_key: { on_delete: :nullify }
      # Seller the inquiry is assigned to.
      t.references :user,    null: true, foreign_key: { on_delete: :nullify }

      t.string :name,  null: false
      t.string :email
      t.string :phone, null: false
      t.text   :message

      t.integer  :status, null: false, default: 0
      t.text     :notes
      t.datetime :contacted_at
      t.datetime :closed_at

      t.timestamps
    end

    add_index :inquiries, :status
    add_index :inquiries, :created_at
    add_index :inquiries, :phone
    add_index :inquiries, [ :status, :created_at ]
  end
end
