class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :event, index: true
      t.references :user, index: true
      t.boolean :private, default: false
      t.string :title
      t.date :day
      t.time :time
      t.text :description

      t.timestamps null: false
    end
    add_foreign_key :activities, :events
    add_foreign_key :activities, :users
  end
end
