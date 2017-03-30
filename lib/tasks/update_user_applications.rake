namespace :user do

  desc "Update existing users to link their membership applications"
  task :update_membership_applications => :environment do

    users = User.all

    users.each do |user|
      ma = MembershipApplication.find_by(email: user.email)
      if ma
        user.membership_application = ma
        user.save!
      end
    end
  end
end