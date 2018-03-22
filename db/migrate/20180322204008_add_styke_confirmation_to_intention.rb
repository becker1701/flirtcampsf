class AddStykeConfirmationToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :stryke_confirmation, :boolean
  end
end
