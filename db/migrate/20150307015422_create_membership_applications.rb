class CreateMembershipApplications < ActiveRecord::Migration
  def change
    create_table :membership_applications do |t|
      t.string :birth_name
      t.string :playa_name
      t.string :email
      t.string :phone
      t.string :home_town
      t.text :possibility
      t.text :contribution
      t.text :passions
      t.integer :years_at_bm
      t.boolean :approved

      t.timestamps null: false
    end
  end
end