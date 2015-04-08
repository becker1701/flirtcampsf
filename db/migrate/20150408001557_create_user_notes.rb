class CreateUserNotes < ActiveRecord::Migration
  def change
    create_table :user_notes do |t|
      t.references :user, index: true
      t.text :note

      t.timestamps null: false
    end
    add_foreign_key :user_notes, :users
  end
end
