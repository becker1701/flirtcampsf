class ChangePrivateToPublishInActivites < ActiveRecord::Migration
  def change
  	remove_column :activities, :private
  	add_column :activities, :publish, :boolean, default: false
  end
end
