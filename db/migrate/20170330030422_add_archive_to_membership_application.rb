class AddArchiveToMembershipApplication < ActiveRecord::Migration
  def change
    add_column :membership_applications, :archived, :boolean, default: false
  end
end
