module MembershipApplicationsHelper

	def display_name(member_app)
		# debugger
		if member_app.playa_name.blank? && member_app.birth_name.blank?
			""
		elsif member_app.playa_name.blank? 
			member_app.birth_name
		else
			member_app.playa_name
		end
	end


end