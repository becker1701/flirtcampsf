require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

	def setup
		@activity = Activity.new(
			  event: events(:future), 
			  user: users(:archer),
			  publish: false,
			  title: "MyString",
			  day: "2015-08-23",
			  time: "2015-08-23 13:00:00",
			  description: "MyText"
			)
	end

	test "is valid" do 
		assert @activity.valid?
	end

	test "is invalid without event" do
		@activity.event = nil
		assert_not @activity.valid?
	end

	test "is invalid without day" do
		@activity.day = nil
		assert_not @activity.valid?
	end

	test "is invalid without time" do
		@activity.time = nil
		assert_not @activity.valid?
	end

	test "is invalid without title" do
		@activity.title = " "
		assert_not @activity.valid?
	end

	
end
