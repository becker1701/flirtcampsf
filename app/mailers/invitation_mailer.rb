class InvitationMailer < ApplicationMailer

	def invite(invitation)
		@invitation = invitation
		mail to: @invitation.email, subject: "You have been invited to Flirt Camp!", from: "campmaster@flirtcampsf.com"
	end

	# def approved(membership_app)
	# 	@membership_app = membership_app
	# 	mail to: @membership_app.email, subject: "Your Flirt Camp application has been approved!"
	# end
end
