class ExistingMemberRequestsController < ApplicationController
  
  def new
  	@existing_member_request = MembershipApplication.new
  end

  def create
  	# debugger
  	@existing_member_request = MembershipApplication.new(existing_member_request_params)
  	if @existing_member_request.save
  		flash[:success] = "Your request has been submitted."
  		redirect_to root_url
  	else
  		render :new
  	end
  end

private

	def existing_member_request_params
		params.require(:membership_application).permit(:name, :playa_name, :email)
	end

end
