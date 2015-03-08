# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(	name: "Brian Becker", 
				email: "campmaster@flirtcampsf.com", 
				password: "123456", 
				password_confirmation:"123456",
				playa_name: "Camp Master", 
				admin: true,
				activated: true,
				activated_at: Time.zone.now)

40.times do |n|
	name = Faker::Name.name
	email = "example-#{n}@example.com"
	password = "123456"
	
	User.create!(	name: name, 
					email: email, 
					playa_name: "Camper#{n}", 
					password: password, 
					password_confirmation: password, 
					activated: true,
					activated_at: Time.zone.now)
end