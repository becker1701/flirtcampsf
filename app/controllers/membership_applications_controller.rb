class MembershipApplicationsController < ApplicationController

	before_action :logged_in_user, only: [:index, :edit, :approve, :decline]
	before_action :admin_user, only: [:index, :edit, :approve, :decline]
	before_action :get_membership_app, only: [:edit, :approve, :decline, :thank_you]


	def index
		@membership_applications = MembershipApplication.all.order(:created_at)
	end

	def new
		@membership_app = MembershipApplication.new
	end
	

	def create
		# debugger
		@membership_app = MembershipApplication.new(membership_app_params)
		if @membership_app.save
			flash[:success] = "Thank you for filling out our application!"

			MembershipApplicationsMailer.thank_you(@membership_app).deliver_now
			MembershipApplicationsMailer.organizer_notification(@membership_app).deliver_now
			redirect_to thank_you_membership_application_url(@membership_app) 
		
		else
			render :new
		end
	end

	def edit
	end

	def approve
		@membership_app.approve
		redirect_to membership_applications_url
	end

	def decline
		@membership_app.decline
		redirect_to membership_applications_url
	end

	def thank_you
	end

	# def existing_member
	# 	@member = MembershipApplication.new
	# end

	# def existing_members_create
	# 	@member = MembershipApplication.new(membership_app_params)
	# 	if @member.save
	# 		redirect_to root_url
	# 	else
	# 		render :existing_member
	# 	end
	# end

private
# 
	def membership_app_params
		params.require(:membership_application).permit(:name, :playa_name, :email, :phone, :home_town, :possibility, :contribution, :passions, :years_at_bm, :approved)
	end

	def get_membership_app
		@membership_app = MembershipApplication.find_by(id: params[:id])
		redirect_to membership_applications_url unless @membership_app
	end
end
