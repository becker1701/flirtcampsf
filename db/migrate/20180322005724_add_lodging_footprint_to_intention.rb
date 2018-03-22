class AddLodgingFootprintToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :lodging_footprint, :string
  end
end
