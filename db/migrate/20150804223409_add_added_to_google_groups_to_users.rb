class AddAddedToGoogleGroupsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :added_to_google_group, :boolean, default: false
  end
end
