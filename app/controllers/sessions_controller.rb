class SessionsController < ApplicationController
  def new
  end

  def create
	if User.where(email: params[:session][:email].downcase).exists?
      user = User.find_by(email: params[:session][:email].downcase)
    end

    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
	else
      flash.now[:danger] = 'El usuario o contraseña no válidos'
      render 'new'
    end
  end

  def destroy
	log_out if logged_in?
	redirect_to root_url
  end
end
