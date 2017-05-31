class AddCampDetailsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :organizer_id, :integer, index: true
    add_column :events, :accepting_apps, :boolean
    add_column :events, :camp_dues_mail, :string
    add_column :events, :camp_dues_paypal, :string
    add_foreign_key :events, :users, column: :organizer_id


  end

end
