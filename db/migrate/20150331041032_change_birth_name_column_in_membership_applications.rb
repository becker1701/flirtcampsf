class ChangeBirthNameColumnInMembershipApplications < ActiveRecord::Migration
  def change
  	rename_column :membership_applications, :birth_name, :name
  end
end
