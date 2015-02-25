# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name: "Brian Becker", email: "becker1701@gmail.com", password: "123456", password_confirmation:"123456", admin: true)

99.times do |n|
	name = Faker::Name.name
	email = "example-#{n}@example.com"
	password = "123456"
	
	User.create!(name: name, email: email, password: password, password_confirmation: password)
end