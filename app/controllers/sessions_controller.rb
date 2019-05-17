class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.where(email: params[:session][:email].downcase)
    if user.exists? && user.authenticate(params[:session][:password])
	else
      flash.now[:danger] = 'El usuario o contraseña no válidos'
      render 'new'
    end
  end

  def destroy
  end
end
