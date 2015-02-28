class StaticPagesController < ApplicationController
  def home
    # 
    if logged_in?
      redirect_to current_user
    end
  end

  def about
  end

  def help
  end

  def contact
  end

  def terms_of_use
  end

  # def notes
  # end

private

end
