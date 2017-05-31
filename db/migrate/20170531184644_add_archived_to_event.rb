class AddArchivedToEvent < ActiveRecord::Migration
  def change
    add_column :events, :archive, :boolean, default: false
  end
end
