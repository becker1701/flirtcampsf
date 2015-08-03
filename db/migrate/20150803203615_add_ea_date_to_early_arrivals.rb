class AddEaDateToEarlyArrivals < ActiveRecord::Migration
  def change
    add_column :early_arrivals, :ea_date, :date
  end
end
