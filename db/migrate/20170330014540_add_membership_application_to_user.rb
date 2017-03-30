class AddMembershipApplicationToUser < ActiveRecord::Migration
  def change
    add_reference :users, :membership_application, index: true
    add_foreign_key :users, :membership_applications
  end
end
