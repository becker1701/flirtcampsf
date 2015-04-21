class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :intention, index: true
      t.date :payment_date
      t.decimal :amount, default: 0

      t.timestamps null: false
    end
    add_foreign_key :payments, :intentions
  end
end
