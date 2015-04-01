class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :name
      t.string :email
      t.integer :admission_qty
      t.integer :parking_qty
      t.string :confirmation_number
      t.references :event, index: true

      t.timestamps null: false
    end
    add_foreign_key :tickets, :events
  end
end
