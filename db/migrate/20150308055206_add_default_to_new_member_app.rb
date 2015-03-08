class AddDefaultToNewMemberApp < ActiveRecord::Migration
  def change
  	change_column :membership_applications, :approved, :boolean, default: false
  end
end
