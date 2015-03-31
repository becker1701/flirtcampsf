module MembershipApplicationsHelper

	def display_name(user)
		# debugger
		return "" if user.nil?

		if user.playa_name.blank? && user.name.blank?
			""
		elsif user.playa_name.blank? 
			user.name
		else
			user.playa_name
		end
	end


end