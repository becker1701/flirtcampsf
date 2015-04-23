require 'test_helper'

class CampDuesNotificationsMailerTest < ActionMailer::TestCase


  test "camp_dues_notification" do

  	user = users(:archer)

	#status: going - no yurt storage & no payments
	intention = user.next_event_intention
	intention.toggle!(:storage_tenent)
	assert_not user.next_event_intention.storage_tenent?

    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_equal "Flirt Camp - Camp Dues!!", mail.subject
    assert_equal ["#{user.email}"], mail.to
    assert_equal ["campmaster@flirtcampsf.com"], mail.from
    assert_match "Howdy #{user.playa_name}!", mail.body.encoded

    assert_match "Camp Dues: $100", mail.body.encoded
    assert_match "Camp Meals: $50", mail.body.encoded
    assert_match "No payments recorded yet", mail.body.encoded
    assert_match "Dues Remaining: $150", mail.body.encoded
    assert_no_match "Annual yurt storage", mail.body.encoded

    assert_match "Options for payment:", mail.body.encoded



	p_1 = user.payments.create(event: events(:future), payment_date: '2015-04-15', amount: 100)

	#status: going - no yurt storage
	# intention = user.next_event_intention
	# intention.toggle!(:storage_tenent)
	assert_not user.next_event_intention.storage_tenent?

    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_equal "Flirt Camp - Camp Dues!!", mail.subject
    assert_equal ["#{user.email}"], mail.to
    assert_equal ["campmaster@flirtcampsf.com"], mail.from
    assert_match "Howdy #{user.playa_name}!", mail.body.encoded

    assert_match "Camp Dues: $100", mail.body.encoded
    assert_match "Camp Meals: $50", mail.body.encoded
    assert_match "$100 on Wed, Apr 15", mail.body.encoded
    assert_match "Dues Remaining: $50", mail.body.encoded
    assert_no_match "Annual yurt storage", mail.body.encoded

    assert_match "Options for payment:", mail.body.encoded

	#status: going - yurt storage

    intention = user.next_event_intention
    intention.toggle!(:storage_tenent)
    intention.camp_due_storage = 75
    intention.save
    user.reload

    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_equal "Flirt Camp - Camp Dues!!", mail.subject
    assert_equal ["#{user.email}"], mail.to
    assert_equal ["campmaster@flirtcampsf.com"], mail.from
    assert_match "Howdy #{user.playa_name}!", mail.body.encoded

    assert_match "Camp Dues: $100", mail.body.encoded
    assert_match "Camp Meals: $50", mail.body.encoded
    assert_match "$100 on Wed, Apr 15", mail.body.encoded
    assert_match "Dues Remaining: $125", mail.body.encoded
    assert_match "Annual yurt storage: $75", mail.body.encoded

    assert_match "Options for payment:", mail.body.encoded


	#status: going - yurt storage & no meals

    intention = user.next_event_intention
    
    intention.toggle!(:opt_in_meals)
    intention.save
    user.reload

    assert_not user.next_event_intention.opt_in_meals?

    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_equal "Flirt Camp - Camp Dues!!", mail.subject
    assert_equal ["#{user.email}"], mail.to
    assert_equal ["campmaster@flirtcampsf.com"], mail.from
    assert_match "Howdy #{user.playa_name}!", mail.body.encoded

    assert_match "Camp Dues: $100", mail.body.encoded
    assert_match "Opted Out", mail.body.encoded
    assert_match "Opt In by updating your camp questionairre", mail.body.encoded
    assert_match "$100 on Wed, Apr 15", mail.body.encoded
    assert_match "Dues Remaining: $75", mail.body.encoded
    assert_match "Annual yurt storage: $75", mail.body.encoded

    assert_match "Options for payment:", mail.body.encoded


  end


  test "greeting" do
    user = users(:archer)
    #Flirter3
    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_match "Flirter3", mail.body.encoded
    assert_no_match "Archer Baker", mail.body.encoded
    assert_no_match "Archer", mail.body.encoded

    user.name = " "
    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_match "Flirter3", mail.body.encoded
    assert_no_match "Archer Baker", mail.body.encoded
    assert_no_match "Archer", mail.body.encoded

    user.reload
    user.playa_name = nil
    mail = CampDuesNotificationsMailer.camp_dues_notification(user)
    assert_no_match "Flirter3", mail.body.encoded
    assert_no_match "Archer Baker", mail.body.encoded
    assert_match "Archer", mail.body.encoded


  end
end
