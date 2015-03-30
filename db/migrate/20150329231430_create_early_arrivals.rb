class CreateEarlyArrivals < ActiveRecord::Migration
  def change
    create_table :early_arrivals do |t|
      t.references :event, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :early_arrivals, :events
    add_foreign_key :early_arrivals, :users
  end
end
