require 'test_helper'

class NoteTest < ActiveSupport::TestCase

  def setup 
  	@note = Note.new(chapter: 1, note: "This ia a note")
  end

  test "is valid" do
  	assert @note.valid?
  end


  
end
