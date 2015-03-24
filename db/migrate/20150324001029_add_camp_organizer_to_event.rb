class AddCampOrganizerToEvent < ActiveRecord::Migration
  def change
    add_column :events, :camp_org, :integer
  end
end
