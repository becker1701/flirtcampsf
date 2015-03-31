class InvitationsController < ApplicationController

	before_action :logged_in_user, except: [:edit]
	before_action :admin_user, except: [:edit]

	def new
		@invitations = Invitation.all.order(:created_at)
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
			flash[:danger] = "Ah, darn it.  Something went wrong."
			redirect_to root_url
		end
	end

	def update
		redirect_to root_url
	end

	def destroy
		invitation = Invitation.find_by(id: params[:id])
		invitation.destroy
		flash[:success] = "Invitation rescended."
		redirect_to new_invitation_path
	end

	def resend
		@invite = Invitation.find_by(id: params[:id])
		if @invite
			@invite.resend
			flash[:success] = "Invitation resent."
		end
		redirect_to new_invitation_url
	end

private

	def invitation_params
		params.require(:invitation).permit(:name, :email)
	end

end
