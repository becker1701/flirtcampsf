module MembershipApplicationsHelper

	def display_name(user)
		# debugger
		return "" if user.nil?

		if user.playa_name.blank? && user.birth_name.blank?
			""
		elsif user.playa_name.blank? 
			user.birth_name
		else
			user.playa_name
		end
	end


end