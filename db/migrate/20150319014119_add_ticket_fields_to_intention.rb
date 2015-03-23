class AddTicketFieldsToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :tickets_for_sale, :integer
  end
end
