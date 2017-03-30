module MembershipApplicationsHelper

  def display_name(user, options = {})
    # binding.pry

    opt = {first_name_only: false}.merge(options)
    return "" if user.nil?

    # puts opt

    if user.playa_name.blank? && user.name.blank?
      "(no name)"
    elsif user.playa_name.blank?
      if opt[:first_name_only]
        user.first_name
      else
        user.name
      end
    else
      user.playa_name
    end
  end


end