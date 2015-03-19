class ChangeUserIntentionTableName < ActiveRecord::Migration
  def change
  	rename_table :user_intentions, :intentions
  end
end
