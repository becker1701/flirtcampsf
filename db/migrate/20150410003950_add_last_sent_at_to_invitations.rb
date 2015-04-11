class AddLastSentAtToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :last_sent_at, :datetime
  end
end
