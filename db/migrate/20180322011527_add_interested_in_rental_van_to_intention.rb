class AddInterestedInRentalVanToIntention < ActiveRecord::Migration
  def change
    add_column :intentions, :interested_in_rental_van, :boolean
  end
end
