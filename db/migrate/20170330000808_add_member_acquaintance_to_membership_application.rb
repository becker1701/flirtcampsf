class AddMemberAcquaintanceToMembershipApplication < ActiveRecord::Migration
  def change
    add_column :membership_applications, :member_acquaintance, :text
  end
end
