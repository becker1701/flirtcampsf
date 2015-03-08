class MembershipApplicationsController < ApplicationController


	def new
		@membership_app = MembershipApplication.new
	end
	

	def create
		# debugger
		@membership_app = MembershipApplication.new(membership_app_params)
		if @membership_app.save
			flash[:success] = "Thank you for filling out our application!"
			redirect_to thank_you_membership_application_url(@membership_app) 
		else
			render :new
		end
	end

	def thank_you
		@membership_app = MembershipApplication.find_by(id: params[:id])
	end


private
# 
	def membership_app_params
		params.require(:membership_application).permit( :birth_name, :playa_name, :email, :phone, :home_town, :possibility, :contribution, :passions, :years_at_bm, :approved)
	end
end
