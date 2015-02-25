require 'test_helper'

class UserIndexTest < ActionDispatch::IntegrationTest
  def setup
  	@user = users(:brian)
    @admin = users(:admin)
    @non_admin = users(:archer)
  end

  test "index page paginates" do
  	log_in_as @admin
  	get users_path
  	assert_template 'users/index'
  	assert_select 'div.pagination'
  	User.paginate(page: 1).each do |user|
  		assert_select 'a[href=?]', user_path(user), text: user.name

      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'Delete', method: :delete
      end
  	end

    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end

  end

  test "delete link only shows for admin" do
    log_in_as @non_admin
    get users_path
    assert_select 'a', text: 'Delete', count: 0
  end
end
