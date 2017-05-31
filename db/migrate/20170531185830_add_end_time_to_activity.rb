class AddEndTimeToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :end_time, :time
  end
end
