require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase

  # def setup
  #   @base_title = "Ruby on Rails Sample Tutorial App" 
  # end

  test "should get home" do
    get :home
    assert_response :success
    # assert_select "title", "#{@base_title}"
    assert_select "title", full_title
  end

  test "should get about" do
    get :about
    assert_response :success
    # assert_select "title", "About | #{@base_title}"
    assert_select "title", full_title("About")
  end

  test "should get help" do
    get :help
    assert_response :success
    # assert_select "title", "Help | #{@base_title}"
    assert_select "title", full_title("Help")
  end

  test "should get contact" do
    get :contact
    assert_response :success
    # assert_select "title", "Contact | #{@base_title}"
    assert_select "title", full_title("Contact")
  end

  test "should get terms of use" do
    get :terms_of_use
    assert_response :success
    # assert_select "title", "Terms of Use | #{@base_title}"
    assert_select "title", full_title("Terms of Use")
  end

  # test "should get notes" do
  #   get :notes
  #   assert_response :success
  #   # assert_select "title", "Notes | #{@base_title}"
  #   assert_select "title", full_title("Notes")
  # end

end
