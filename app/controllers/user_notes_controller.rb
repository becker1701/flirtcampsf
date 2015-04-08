class UserNotesController < ApplicationController

	before_action :logged_in_user
	before_action :admin_user
	before_action :get_user

	def index
		@user_notes = @user.user_notes.order(:created_at)
	end

	def new
		@user_note = @user.user_notes.build
	end 

	def create
		@user_note = @user.user_notes.build(user_note_params)
		if @user_note.save
			flash[:success] = "Note saved"
			redirect_to user_user_notes_url(@user)
		else
			render :new
		end
		
	end

	def edit
		@user_note = @user.user_notes.find_by(id: params[:id])
	end

	def update
		@user_note = @user.user_notes.find_by(id: params[:id])
		
		if @user_note.update_attributes(user_note_params)
			flash[:success] = "Note updated"
			redirect_to user_user_notes_url(@user)
		else
			render :edit
		end
	end

	def destroy
		@user_note = @user.user_notes.find_by(id: params[:id]).destroy
		flash[:success] = "Note deleted"
		redirect_to user_user_notes_url(@user)
	end

private

	def user_note_params
		params.require(:user_note).permit(:user_id, :note)
	end

	def get_user
		@user = User.find_by(id: params[:user_id])
	end

end
