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
	email = "example-#{n}_user@example.com"
	password = "123456"
	
	User.create!(	name: name, 
					email: email, 
					playa_name: "Camper#{n}", 
					password: password, 
					password_confirmation: password, 
					activated: true,
					activated_at: Time.zone.now)
end

10.times do |n|

	email = "example-#{n}_invitation@example.com"
	invite_digest = Invitation.digest('invite_012345')

	Invitation.create!(
		name: Faker::Name.name,
		email: email,
		invite_digest: invite_digest
	)
end

10.times do |n|

	name = Faker::Name.name
	email = "example-#{n}_member_app@example.com"
	phone = Faker::PhoneNumber.phone_number
	city = Faker::Address.city_prefix
	state = Faker::Address.state_abbr
	if n % 3 == 0
		approved = true
	elsif n % 7 == 0
		approved = false
	end 

	MembershipApplication.create!(
		birth_name: name,
		playa_name: name,
		email: email,
		phone: phone,
		home_town: "#{city}, #{state}",
		possibility: "MyText",
		contribution: "MyText",
		passions: "MyText",
		years_at_bm: "#{n}",
		approved: approved
  	)

end