class AddMembershipApplicationIdToInvitation < ActiveRecord::Migration
  def change
    add_reference :invitations, :membership_application, index: true
    add_foreign_key :invitations, :membership_applications
  end
end
