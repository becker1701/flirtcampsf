class AddEventAndUserToPayments < ActiveRecord::Migration
  def change
    add_reference :payments, :user, index: true
    add_foreign_key :payments, :users
    add_reference :payments, :event, index: true
    add_foreign_key :payments, :events

    remove_columns :payments, :intention_id
    # remove_index :payments, :intention_id
  end
end
