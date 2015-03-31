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
				hometown: "San Francisco, CA",
				admin: true,
				activated: true,
				activated_at: Time.zone.now)

30.times do |n|
	name = Faker::Name.name
	email = "example-#{n}_user@example.com"
	password = "123456"
	
	User.create!(	name: name, 
					email: email, 
					playa_name: "Camper#{n}", 
					hometown: "#{Faker::Address.city_prefix}, #{Faker::Address.state_abbr}",
					password: password, 
					password_confirmation: password, 
					activated: true,
					activated_at: Time.zone.now)
end

#create upcoming event
future_event = Event.create!(
	year: "Burning Man 2015",
	start_date: Date.today + 120.days,
	end_date: Date.today + 130.days,
	theme: "Carnival of Mirrors",
	camp_address: "9:00 & Flirt",
	early_arrival_date: Date.today + 115.days
	)

past_event = Event.create!(
	year: "Burning Man 2014",
	start_date: Date.today - 130.days,
	end_date: Date.today - 120.days,
	theme: "Old",
	camp_address: "9:00 & Flirt",
	early_arrival_date: Date.today - 135.days
	)

# event = Event.last

User.all.each do |user|

	status_id = rand(0..5)

	case status_id
	when 1
		status = :going_has_ticket
		num_ticket = 1
	when 2
		status = :going_needs_ticket
		num_ticket = 0
	when 3
		status = :not_going_has_ticket
		num_ticket = 2
	when 4
		status = :not_going_no_ticket
		num_ticket = 0
	else
		status = false
	end

	future_event.intentions.create!(status: status, user: user, arrival_date: Date.today + 120.days, departure_date: Date.today + 130.days, tickets_for_sale: num_ticket) unless status == false
	past_event.intentions.create!(status: status, user: user, arrival_date: Date.today - 130.days, departure_date: Date.today - 120.days, tickets_for_sale: 0) unless status == false
end

# debugger
intentions = future_event.intentions.where(status: [1,2])
counter = rand(0..3)

intentions.each do |intention|
	counter.times do |n|
		# debugger
		
		activity_time = Faker::Time.between(future_event.start_date, future_event.end_date)
		# activity_date = Faker::Date.between(event.start_date, event.end_date)

		future_event.activities.create!(
			user: intention.user,
			publish: n%2 == 0 ? false : true,
			title: Faker::Lorem.sentence(3).humanize,
			day: activity_time,
			time: activity_time,
			description: Faker::Lorem.paragraph)
	end
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
		name: name,
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



