class InvitationsController < ApplicationController

	before_action :logged_in_user, except: [:edit]
	before_action :admin_user, except: [:edit]

	def new
		@invitation = Invitation.new
	end

	def create
		@invitation = Invitation.new(invitation_params)
		if @invitation.save
			
			flash[:success] = "Invitation added."
			redirect_to new_invitation_url
			@invitation.send_invitation_email
		else

			render :new
		end
	end

	def edit
		# debugger
		@invitation = Invitation.find_by(email: params[:email]) if params[:email]
		if @invitation && @invitation.authenticated?(:invite, params[:id])
			flash[:success] = "Create your Flirt Camp Profile!"
			redirect_to signup_url(invite: @invitation.id)
		else
			flash[:danger] = "Ah, darn it.  The token used for your email address does not match."
			redirect_to root_url
		end
	end

	def update
		redirect_to root_url
	end

	def destroy
		redirect_to root_url
	end

private

	def invitation_params
		params.require(:invitation).permit(:name, :email)
	end

end
