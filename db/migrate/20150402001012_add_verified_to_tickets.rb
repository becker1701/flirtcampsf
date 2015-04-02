class AddVerifiedToTickets < ActiveRecord::Migration
  def change
  	add_column :tickets, :verified, :boolean, default: false
  end
end
