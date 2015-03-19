class AddFieldsToIntentions < ActiveRecord::Migration
  def change

    add_column :intentions, :arrival_date, :date
    add_column :intentions, :departure_date, :date
    add_column :intentions, :transportation, :integer #driving, carpool, bus, other
    add_column :intentions, :seats_available, :integer 
    add_column :intentions, :lodging, :integer #1=tent, 2=yurt
    add_column :intentions, :yurt_owner, :boolean, default: false
    add_column :intentions, :yurt_storage, :boolean, default: false
    add_column :intentions, :yurt_panel_size, :string
    add_column :intentions, :yurt_user, :string
    add_column :intentions, :opt_in_meals, :boolean
    add_column :intentions, :food_restrictions, :text
    add_column :intentions, :logistics, :text
    add_column :intentions, :event_id, :integer
    add_index :intentions, [:user_id, :event_id]
  end
end
