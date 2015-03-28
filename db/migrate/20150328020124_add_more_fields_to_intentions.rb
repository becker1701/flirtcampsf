class AddMoreFieldsToIntentions < ActiveRecord::Migration
  def change
    add_column :intentions, :storage_bikes, :integer
    add_column :intentions, :logistics_bike, :integer
    add_column :intentions, :logistics_bins, :integer
  end
end
