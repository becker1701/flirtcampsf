ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!


class ActiveSupport::TestCase
	# Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
	fixtures :all

	# Add more helper methods to be used by all tests here...
	include ApplicationHelper

	def is_logged_in?
		# Returns true if a user is logged in
		!session[:user_id].nil?
	end

  
	def log_in_as(user, options = {})

		# password = options[:password] || 'password'
		# remember_me = options[:remember_me] || '1'

		password = options.fetch(:password, 'password')
		remember_me = options.fetch(:remember_me, '1')

		if integration_test?
			post login_path, {email: user.email, password: password, remember_me: remember_me}
		else
			session[:user_id] = user.id
		end
	end

	def log_out
		session.delete(:user_id)
	end

private

	def integration_test?
		defined?(post_via_redirect)
	end

end
