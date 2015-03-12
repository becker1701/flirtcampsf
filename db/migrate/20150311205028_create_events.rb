class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :year
      t.date :start_date
      t.date :end_date
      t.string :theme
      t.string :camp_address
      t.date :early_arrival_date

      t.timestamps null: false
    end
  end
end
