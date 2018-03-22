class AddVehicleTypeToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :vehicle_type, :string
  end
end
