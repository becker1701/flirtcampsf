class AddStatusToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :status, :integer, default: 1
  end
end
