class AddShipYurtToIntentions < ActiveRecord::Migration
  def change
    add_column :intentions, :shipping_yurt, :boolean
  end
end
