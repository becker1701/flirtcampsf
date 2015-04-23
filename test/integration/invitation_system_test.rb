require 'test_helper'

class InvitationSystemTest < ActionDispatch::IntegrationTest
  
	# The invitation sytem is a means to invite folks who are part of the camp or hae been accepted to the camp to
	# create an account.

	# Generating the list of invitees:
	# 1: For members who are already a part of Flirt Camp (i.e. "Direct Add"), ADMIN will be able to add an email address and 
	# name through controller to invitations table.  
	# 2: For members who apply via the site --  ADMIN will mark the membership application as accepted, and an invitation will automaticall be generated, along with the email.

	#The invitation and user creator...
	# The invitations table will generate a token and an invitation digest and send an email to the invitee with a link, 
	# complete with the token and email address of the recipient.
	# Recipient will click on the link in the email, and the controller will cross reference the token and email address with the
	# invitees in the invitations table. 
	# Once the user is validated, the invitation status is updated to "clicked through" and linked to a new user record.
	# The invitee is redirected to a "New Profile" page, where the invitee, now a user, will create their profile.
	# Once the profile is created, they will have full access to the dashboard

	def setup
		@admin = users(:brian)
		@user = users(:archer)
		ActionMailer::Base.deliveries.clear
	end

	test "invite process with current member" do

		get new_invitation_path

		assert_redirected_to login_url
		assert_not is_logged_in?

		log_in_as @admin
		assert is_logged_in?

		get new_invitation_path

		#test invalid invitation
		assert_no_difference 'Invitation.count' do
			post invitations_path, invitation: { name: " ", email: " " }
		end
		assert_template 'invitations/new'
		# assert_not flash.empty?
		assert_select 'div#error_explanation'

		#test valid invitation
		assert_difference 'Invitation.count', 1 do
			post invitations_path, invitation: { name: "Some Person", email: "someperson@example.com" }
		end

		invitation = assigns(:invitation)
		invitation.reload
		assert_not invitation.last_sent_at.nil?

		assert_not flash.empty?
		assert_redirected_to new_invitation_path
		follow_redirect!
		assert_template 'invitations/new'

		#assert invitee digest and token are present
		# debugger
		assert_not invitation.invite_token.empty?
		assert_not invitation.invite_digest.empty?

		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		#test mailer to, from and subject
		assert_equal [invitation.email], mail.to
		assert_match invitation.name, mail.body.encoded
		assert_match invitation.invite_token, mail.body.encoded
		assert_match CGI::escape(invitation.email), mail.body.encoded

		delete logout_path
		assert_not is_logged_in?

		
		#test for no invitation token
		get signup_path
		assert_template 'users/new'
		assert assigns(:invite).nil?
		assert flash.empty?	

		#test for invalid token
		#****  Not testing for token values
		
		get edit_invitation_path('invalid_token', email: invitation.email)
		assert_redirected_to signup_path(invite: invitation.id)
		assert_not flash.empty?

		# delete logout_path
		assert_not is_logged_in?

		#test invalid email
		#*****  user will be sent to a blank signup_path without invite_id
		get edit_invitation_path(invitation.invite_token, email: "incorrect email")
		assert_redirected_to signup_path
		assert_not flash.empty?		

		# valid token and email
		# delete logout_path
		assert_not is_logged_in?

		get edit_invitation_path(invitation.invite_token, email: invitation.email)
		
		# delete logout_path
		assert_not is_logged_in?

		assert_redirected_to signup_path(invite: invitation.id)		
		follow_redirect!
		assert_equal invitation, assigns(:invite)
		assert_template 'users/new'
		# debugger
		
		assert_select "input[value=?]", invitation.id.to_s
		assert_select "input[value=?]", invitation.name.to_s
		assert_select "p.form-static-control", invitation.email.to_s
		
		delete logout_path
		assert_not is_logged_in?
		log_in_as @admin
		ActionMailer::Base.deliveries.clear

		#test valid invitation
		assert_difference 'Invitation.count', 1 do
			post invitations_path, invitation: { name: "Some Person 123", email: "someperson123@example.com" }
		end

		#get instance from create
		new_invite = assigns(:invitation)
		#make sure the name matches the instance
		assert_equal "Some Person 123", new_invite.name
		# make sure the email was sent
		assert_equal 1, ActionMailer::Base.deliveries.count
		
		#******  Delete the invitation and make sure the user is sent to the signup page anyways, but without the invite_id
		delete invitation_path(new_invite)

		delete logout_path
		assert_not is_logged_in?

		get edit_invitation_path(new_invite.invite_token, email: new_invite.email)
		assert_redirected_to signup_path
		assert_not is_logged_in?
		assert_not flash.empty?



	end


	test "invite process with new member" do

		@membership_app = membership_applications(:first)

		#redirect when trying to access membership apps without being logged in
		
		get membership_applications_path
		assert_not is_logged_in?
		assert_redirected_to login_path
		assert_not flash.empty?

		# redirect non-admin to root_url
		log_in_as @user
		assert is_logged_in?
		get membership_applications_path
		assert_redirected_to root_url
		assert_not flash.empty?

		delete logout_path
		assert_not is_logged_in?

		log_in_as @admin
		get membership_applications_path
		assert_template 'membership_applications/index'

		MembershipApplication.all.each do |member_app|
			assert_select "a[href=?]", edit_membership_application_path(member_app)
			if member_app.approved?
				assert_select "tr.success"
			elsif !member_app.approved?
				assert_select "tr.danger"
			end
		end

		assert_select "a[href=?]", edit_membership_application_path(@membership_app)

		# test bad membership application
		get edit_membership_application_path('invalid')
		assert_redirected_to membership_applications_path

		#good membership appl
		get edit_membership_application_path(@membership_app)
		# assert_redirected_to edit_membership_application_path(@membership_app)
		# follow_redirect!
		assert_template "membership_applications/edit"
		assert_match @membership_app.name, response.body
		assert_match @membership_app.playa_name, response.body
		assert_match @membership_app.email, response.body
		assert_select "a", "Approve"
		assert_select "a", "Decline"
		assert_select "a[href=?]", approve_membership_application_path(@membership_app)
		assert_select "a[href=?]", decline_membership_application_path(@membership_app)

		assert_not @membership_app.approved?
		
		# decline membership
		assert_no_difference 'Invitation.count' do
			get decline_membership_application_path(@membership_app)
		end
		assert_not @membership_app.reload.approved?
		assert_redirected_to membership_applications_path

		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		assert_equal "Your Flirt Camp application has been declined.", mail.subject

		ActionMailer::Base.deliveries.clear

		# accept membership
		@membership_app.approved = nil

		assert_difference 'Invitation.count', 1 do
			get approve_membership_application_path(@membership_app)
		end

		assert @membership_app.reload.approved?
		assert_redirected_to membership_applications_path


		assert_equal 1, ActionMailer::Base.deliveries.count
		mail = ActionMailer::Base.deliveries.last
		assert_equal "You have been invited to Flirt Camp!", mail.subject

		#test when the invitation is deleted, user redirected to root_url



	end

	test "index displays on new page" do
		# skip
		log_in_as @admin
		assert is_logged_in?

		get new_invitation_path
		assert_template 'invitations/new'

		invites = assigns(:invitations)
		assert_equal 12, invites.count

		invites.last(3).each do |invite|
			User.create!(name: invite.name, email: invite.email, password: "123456", password_confirmation: "123456")
		end
		invites.reload
		get new_invitation_path

		# invites.first.update_attribute(:last_sent_at, nil)

		invites.each do |invite|
			assert_select 'div[id=?]', "invite_id_#{invite.id}", count: 1 do
				if invite.replied?
					assert_select 'span.label-success', text: "Yes"
					assert_select 'a[href=?]', resend_invitation_path(invite), count: 0
				else
					# debugger
					assert_select 'span.label-warning', text: "No"
					assert_select 'a[href=?]', resend_invitation_path(invite), count: 1
				end

				# debugger
				if invite.last_sent_at.nil?
					assert_select 'td[id=?]', "last_sent_at_#{invite.id}", text: "Not Sent"
				else
					assert_select 'td[id=?]', "last_sent_at_#{invite.id}", invite.last_sent_at.localtime.strftime("%m/%d/%Y at %I:%M%p")
				end
			end
		end
	end


	test "resend invitation from index" do
		
		invite = invitations(:one)
		invite_last_sent = invite.last_sent_at

		log_in_as @admin
		assert is_logged_in?

		get new_invitation_path
		assert_template 'invitations/new'

		get resend_invitation_path(invite)

		assert_equal invite.id, assigns(:invite).id
		assert_not_equal invite_last_sent, assigns(:invite).last_sent_at

		assert_equal 1, ActionMailer::Base.deliveries.count
		#mailer already tested

		assert_redirected_to new_invitation_path
		follow_redirect!
		assert_template 'invitations/new'
		assert_not flash.empty?
		assert_select 'a[href=?]', resend_invitation_path(invite), count: 1

	end

	test "remove existing invitation" do

		log_in_as @admin
		get new_invitation_path

		invites = assigns(:invitations)

		first_invite = invitations(:one)
		# debugger

		invites.each do |invite|
			
			assert_select 'a[href=?]', invitation_path(invite), method: :delete

			if invite.replied?
				assert_select 'span.label-success'
			else
				assert_select 'span.label-warning'
			end
		end

		#delete button works to remove 
		assert_difference 'Invitation.count', -1 do
			delete invitation_path(first_invite)
		end

		assert_redirected_to new_invitation_path
		follow_redirect!
		assert_template 'invitations/new'

		assert_select 'a[href=?]', invitation_path(first_invite), method: :delete, count: 0

		#if invitation sent, make sure the email recipient can not get to the user create page


	end


	test "admin add invite and reset invite token still works" do
=begin
		When Admin enters an invitation, the invitation_token and invitation_digest will be set. The
		Invitation_token is a virtual attribute and will not persist.  The goal of this test is to test:
		1. Admin creates an invitation complete with token and digest
		2. Admin "resends" invitation, thus updating the digest with a new token
		3. User can access the invitaion via the initial link with the old token and still reach the signup_path
		without error

		admin is :brian

=end
		# @user.invitations.destroy_all

		log_in_as @admin

		assert_difference 'Invitation.count', 1 do
			post invitations_path, invitation: { name: "Some Person 123", email: "someperson123@example.com" }
		end
		
		# assert_equal 1, ActionMailer::Base.deliveries.count

		invite = assigns(:invitation)
		assert_not invite.nil?

		# old_invite_token = invite.invite_token
		
		# debugger
		get resend_invitation_path(invite)
		
		new_invite = assigns(:invite)

		# ensure the same invite is pulled back from the resend method
		assert_equal invite.id, new_invite.id
		#and the check to see if the token changed
		assert_not_equal invite.invite_token, new_invite.invite_token
		assert_redirected_to new_invitation_path

		#log out admin so there is no session as user clicks links in email
		delete logout_path
		assert_not is_logged_in?

		#user clicks link in email
		# puts "Old token: #{invite.invite_token}"
		# puts "New token: #{new_invite.invite_token}"

		assert_not new_invite.authenticated?(:invite, invite.invite_token)

		get edit_invitation_url(invite.invite_token, email: invite.email)
		# debugger
		assert_redirected_to signup_path(invite: invite.id)
		follow_redirect!
		assert_not assigns(:invite).nil?

	end

	test "user signup from invite activated on create with correct invite ID" do
		
		log_in_as @admin
		
		invite = Invitation.create!(name: "Some Person 123", email: "someperson123@example.com")

		delete logout_path
		assert_not is_logged_in?
		
		get edit_invitation_url(invite.invite_token, email: invite.email)


	end

	test "resend invites to all unanswered invitations" do
		log_in_as @admin
		get resend_all_invitations_path

		not_replied_count = 0

		Invitation.all.each do |invite|
			if invite.replied?
				#do nothing
			else
				not_replied_count += 1
			end
		end

		assert_equal not_replied_count, ActionMailer::Base.deliveries.count

	end

	test "email links located on page" do
		log_in_as @admin
		get new_invitation_path
		invites = assigns(:invitations)
		invites.each do |invite|
			# binding.pry
			assert_select 'a[href=?]', "mailto:#{invite.email}"
		end
	end

end
