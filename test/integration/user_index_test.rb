require 'test_helper'

class UserIndexTest < ActionDispatch::IntegrationTest
  def setup
  	@user = users(:brian)
    @admin = users(:admin)
    @non_admin = users(:archer)
    @not_activated = users(:not_activated)
  end

  test "index page paginates" do
  	log_in_as @admin
  	get users_path
  	assert_template 'users/index'
  	assert_select 'div.pagination'

    assert_not assigns(:next_event).nil?
    next_event = assigns(:next_event)

    users = assigns(:users)

  	users.each do |user|
  		# puts "#{user.id}, #{user.activated?}"
      assert_select 'a[href=?]', user_path(user), text: "#{user.playa_name} (aka #{user.name})"
      assert user.activated?

      if user.next_event_intention
        assert_select 'div[id=?]', "user_id_#{user.id}", text: user.next_event_intention.status.humanize
      else
        assert_select 'div[id=?]', "user_id_#{user.id}", text: "Not responded to #{next_event.year}"
      end

      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'Delete', method: :delete
      end
  	end

    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end

  end

  test "nil next_event shows only message" do
      log_in_as @admin    
      #remove future event to test for index message...
      Event.next_event.delete
      assert_nil Event.next_event
    
      get users_path
      users = assigns(:users)
      assert_nil assigns(:next_event)
      
      users.each do |user|
        assert_select 'div[id=?]', "user_id_#{user.id}", text: "No event scheduled yet..."
      end

  end

  test "delete link only shows for admin" do
    log_in_as @non_admin
    get users_path
    assert_select 'a', text: 'Delete', count: 0
  end

  test "first name alphabetical index" do
    
    log_in_as @non_admin
    get users_path
    
    users = assigns(:users)
    test_users = User.where(activated: true).order(:name).paginate(page: 1)

    assert_equal users.first, test_users.first
    assert_equal users.last, test_users.last

  end

  test "intention status shows on index page" do
    log_in_as @user
    get users_path
    users = assigns(:users)


  end
end
