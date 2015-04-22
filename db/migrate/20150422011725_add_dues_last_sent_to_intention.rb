class AddDuesLastSentToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :dues_last_sent, :datetime
  end
end
