module SessionsHelper

  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    if session[:user_id]
      if User.where(id: session[:user_id])
        @current_user ||= User.find(session[:user_id])
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end
end
