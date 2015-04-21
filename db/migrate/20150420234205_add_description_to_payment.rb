class AddDescriptionToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :description, :text
  end
end
