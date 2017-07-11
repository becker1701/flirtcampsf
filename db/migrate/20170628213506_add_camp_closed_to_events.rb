class AddCampClosedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :camp_closed, :boolean, default: false
  end
end
