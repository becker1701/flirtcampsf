class AddCampDuesToEvent < ActiveRecord::Migration
  def change
    add_column :events, :camp_dues, :decimal, default: 0
    add_column :events, :camp_dues_food, :decimal, default: 0
  end
end
