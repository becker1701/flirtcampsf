require 'test_helper'

class UserAdminNotesTest < ActionDispatch::IntegrationTest
	include MembershipApplicationsHelper
	def setup
		@admin = users(:brian)
		@user = users(:archer)
	end

	test "non admin can not see notes" do
		log_in_as @user
		get user_path(@admin)

		assert_select 'div[id=?]', "admin-user-notes", count: 0
	end

	test "admin can see user notes" do
		log_in_as @admin
		get user_path(@user)
		assert_select 'div[id=?]', "admin-user-notes", count: 1
	end

	test "admin updates user notes" do
		log_in_as @admin
		get user_path(@user)
		assert_select 'a[href=?]', user_user_notes_path(@user), count: 1

		get user_user_notes_path(@user)
		assert_template 'user_notes/index'

		assert_select 'h1', text: "Notes for #{display_name(@user)}"

		assert_equal 5, assigns(:user_notes).count
		user_notes = assigns(:user_notes)
		# debugger	
		user_notes.each do |note|
			assert_select 'tr[id=?]', "user_note_id_#{note.id}" do
				assert_match note.note, response.body
				assert_select 'a', text: "Delete", count: 1
				assert_select 'a[href=?]', user_user_note_path(@user, note), count: 1
			end
		end

		assert_select 'a[href=?]', new_user_user_note_path(@user)

	end

	test "notes link does not display on users index for non admin" do
		log_in_as @user
		get users_path
		assigns(:users).each do |user|
			assert_select 'a[href=?]', new_user_user_note_path(user), count: 0
		end
	end

	test "admin notes link visible on user index" do

		log_in_as @admin
		get users_path

		users = assigns(:users)

		assigns(:users).each do |user|
			if @admin == user
				assert_select 'a[href=?]', new_user_user_note_path(user), count: 0
			else
				assert_select 'a[href=?]', new_user_user_note_path(user), count: 1
			end
		end
	end



end
