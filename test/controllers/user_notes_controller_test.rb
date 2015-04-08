require 'test_helper'

class UserNotesControllerTest < ActionController::TestCase

	include MembershipApplicationsHelper

	def setup
		@user = users(:archer)
		@admin = users(:brian)
		@note = user_notes(:archer_note_1)
	end

	test "redirect on index when not admin" do
		#not a user
		get :index, user_id: @user.id
		assert_redirected_to login_path

		#not an admin
		log_in_as @user
		assert_not @user.admin?
		get :index, user_id: @user.id
		assert_redirected_to root_url
	end

	test "success on index when admin" do
		log_in_as @admin
		get :index, user_id: @user.id
		assert_response :success
		assert_template 'user_notes/index'
		assert_select 'title', full_title("Notes for #{display_name(@user)}")
		assert_equal @user, assigns(:user)
		assert assigns(:user_notes).present?
	end

	test "redirect on new when not admin" do
		#not a user
		get :new, user_id: @user.id
		assert_redirected_to login_path

		#not an admin
		log_in_as @user
		assert_not @user.admin?
		get :new, user_id: @user.id
		assert_redirected_to root_url
	end

	test "success on new when admin" do
		log_in_as @admin
		get :new, user_id: @user.id
		assert_response :success
		assert_template 'user_notes/new'
		assert_select 'title', full_title("New Note for #{display_name(@user)}")
		assert_equal @user, assigns(:user)
		assert assigns(:user_note).new_record?
	end


	test "redirect on create when not admin" do
		#not a user
		assert_no_difference 'UserNote.count' do
			post :create, user_id: @user.id, user_note: {note: "Some note"}
		end
		assert_redirected_to login_path

		#not an admin
		log_in_as @user
		assert_not @user.admin?
		assert_no_difference 'UserNote.count' do
			post :create, user_id: @user.id, user_note: {note: "Some note"}
		end
		assert_redirected_to root_url
	end

	test "render new on invalid create when admin" do
		log_in_as @admin
		assert_no_difference 'UserNote.count' do
			post :create, user_id: @user.id, user_note: {note: " "}
		end
		assert_template 'user_notes/new'
		assert_select 'div[id=?]', "error_explanation"
	end

	test "success on valid create when admin" do
		log_in_as @admin
		assert_difference 'UserNote.count', 1 do
			post :create, user_id: @user.id, user_note: {note: "Some note"}
		end
		assert_redirected_to user_user_notes_path(@user)
		assert_not flash.empty?
		assert_equal "Some note", assigns(:user_note).note
	end



	test "redirect on edit when not admin" do
		#not a user
		get :edit, user_id: @user.id, id: @note
		assert_redirected_to login_path

		#not an admin
		log_in_as @user
		assert_not @user.admin?
		get :edit, user_id: @user.id, id: @note
		assert_redirected_to root_url
	end

	test "success on edit when admin" do
		log_in_as @admin
		get :edit, user_id: @user.id, id: @note
		assert_response :success
		assert_template 'user_notes/edit'
		assert_select 'title', full_title("Edit Note for #{display_name(@user)}")
		assert_equal @user, assigns(:user)
		assert_equal @note, assigns(:user_note)
	end


	test "redirect on update when not admin" do
		#not a user
		assert_no_difference 'UserNote.count' do
			patch :update, user_id: @user.id, id: @note, user_note: {note: "Some note"}
		end
		assert_redirected_to login_path

		#not an admin
		log_in_as @user
		assert_not @user.admin?
		assert_no_difference 'UserNote.count' do
			patch :update, user_id: @user.id, id: @note, user_note: {note: "Some note"}
		end
		assert_redirected_to root_url
	end

	test "render edit on invalid update when admin" do
		log_in_as @admin
		assert_no_difference 'UserNote.count' do
			patch :update, user_id: @user.id, id: @note, user_note: {note: " "}
		end
		assert_template 'user_notes/edit'
		assert_select 'div[id=?]', "error_explanation"
	end

	test "success on valid update when admin" do
		log_in_as @admin
		assert_no_difference 'UserNote.count' do
			patch :update, user_id: @user.id, id: @note, user_note: {note: "Some note"}
		end
		assert_redirected_to user_user_notes_path(@user)
		assert_not flash.empty?
		assert_equal "Some note", assigns(:user_note).note
	end


	test "redirect on destroy when not admin" do
		#not a user
		assert_no_difference 'UserNote.count' do
			delete :destroy, user_id: @user.id, id: @note
		end
		assert_redirected_to login_path

		#not an admin
		log_in_as @user
		assert_not @user.admin?
		assert_no_difference 'UserNote.count' do
			delete :destroy, user_id: @user.id, id: @note
		end
		assert_redirected_to root_url
	end

	test "success on destroy when admin" do
		log_in_as @admin
		assert_difference 'UserNote.count', -1 do
			delete :destroy, user_id: @user.id, id: @note
		end
		assert_redirected_to user_user_notes_path(@user)
		assert_not flash.empty?
		assert_equal @user, assigns(:user)
		assert_equal @note, assigns(:user_note)
	end

end
