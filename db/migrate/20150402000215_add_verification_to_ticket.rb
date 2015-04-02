class AddVerificationToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :verification_digest, :string
    add_column :tickets, :verified_at, :datetime
  end
end
