class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	include SessionsHelper

	private

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Por favor, indentifiquese usted >:C"
        redirect_to login_url
      end
    end
end
