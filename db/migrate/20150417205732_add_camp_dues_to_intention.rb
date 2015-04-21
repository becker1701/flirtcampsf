class AddCampDuesToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :camp_due_storage, :decimal, default: 0
    add_column :intentions, :storage_tenent, :boolean, default: false
  end
end
