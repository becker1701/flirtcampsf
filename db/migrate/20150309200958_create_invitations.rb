class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :name
      t.string :email
      t.string :invite_digest

      t.timestamps null: false
    end
  end
end
