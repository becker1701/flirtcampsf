class AddNumberOccupantsToIntentions < ActiveRecord::Migration
  def change
    add_column :intentions, :lodging_num_occupants, :integer
  end
end
