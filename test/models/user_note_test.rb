require 'test_helper'

class UserNoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = users(:archer)
  	@user_note = @user.user_notes.build(note: "This is a note")
  end

  test "valid" do
  	assert @user_note.valid?
  end

  test "invalid without user_id" do
  	note_without_user = UserNote.new(note: "This is invalid")
  	assert_not note_without_user.valid?
  end

  test "invalid without note" do
  	@user_note.note = " "
  	assert_not @user_note.valid?
  end

  test "invlalif if note is greater than 1000 characters" do
  	@user_note.note = "a" * 1001
  	assert_not @user_note.valid?
  end
  
end
