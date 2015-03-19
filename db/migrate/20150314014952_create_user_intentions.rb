class CreateUserIntentions < ActiveRecord::Migration
  def change
    create_table :user_intentions do |t|
      t.references :user, index: true
      t.integer :status

      t.timestamps null: false
    end
    add_foreign_key :user_intentions, :users
  end
end
