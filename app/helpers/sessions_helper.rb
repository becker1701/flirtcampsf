module SessionsHelper

  def log_in(user)
    #
    session[:user_id] = user.id
  end

  def current_user

    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id) #find_by returns nil if no matching record
    elsif (user_id = cookies.signed[:user_id])
      #
      # raise
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def logout
    if logged_in?
      forget current_user
      session.delete(:user_id)
      @current_user = nil
    end
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
    # puts "cookies[:user_id]: #{cookies[:user_id]}"
    # puts "cookies[:remember_token]: #{cookies[:remember_token]}"
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default_url)
    redirect_to(session[:forwarding_url] || default_url)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def admin_user?
    current_user.admin?
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def logged_in_user
    # debugger
    unless logged_in?
      flash[:danger] = "Please log in."
      store_location
      redirect_to login_url
    end
  end


end
